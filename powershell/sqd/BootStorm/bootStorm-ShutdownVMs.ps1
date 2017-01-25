param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='solidfire',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)
# add params for datastore, power op, vmprefix
# init powercli and SF powershell environments
.\Initialize-PowerCLIEnvironment.ps1
.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

#check storge usage
C:\solidfire\scripts\sqd\bnppcheckUsage.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost

$vms =  Get-VM -Datastore bnppDSC -Server $vcenter
$num = 1
foreach ($vm in $vms)
{
	Write-Output "Power on" $vm
	Stop-VM -Server $vcenter -VM $vm -Confirm:$false -RunAsync
	$num++
}

while((Get-Task -Server $vcenter -Status Running).name -eq 'PowerOffVM_Task') {
write-host "Waiting for poweroff to complete.... sleeping 3 seconds" ; sleep 3 
}

$nope = (Get-VM |Get-View).Guest.ToolsStatus |where {$_ -eq 'toolsNotRunning'} | Measure-Object -Line
$poweredoff = (Get-VM -Datastore bnppDSC).PowerState | where {$_ -eq 'PoweredOff'} | Measure-Object -Line

Write-Output 'Power ops calls made: ' $num
Write-Output 'Powered on vms: ' $poweredoff.lines
Write-Output 'Clones unresponsive: ' $nope.lines

#check storge usage
C:\solidfire\scripts\sqd\bnppcheckUsage.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost

Stop-Transcript
Disconnect-SFCluster -Target $mvip
Disconnect-VIServer -Confirm:$false -Server $vcenter