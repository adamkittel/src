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
# add params for vm prefix, parent vm, # clones, destination
# init powercli and SF powershell environments
#.\Initialize-PowerCLIEnvironment.ps1
#.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$scriptname = $myinvocation.MyCommand.Name
. c:\solidfire\scripts\BootStorm\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

#check storge usage
C:\solidfire\scripts\sqd\bnppcheckUsage.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost

[string]$timestamp = Get-Date -Format "dd-MMM-yyyy-hhmmss"
Write-Output '**Start deploy clones ' $timestamp

# vsphere HA does not seem to be distributing load very well. adding all cluster hosts to the mix in order to manually distribute load
[string]$esxhost2 = '172.26.254.43'
[string]$esxhost3 = '172.26.254.44'

$num = 1
1..180 | foreach {
	[string]$vm = 'win7-' + $num
	New-VM -Datastore bnppDSC -VM Windows7 -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
	$num++
	[string]$vm = 'win7-' + $num
	New-VM -Datastore bnppDSC -VM Windows7 -VMHost $esxhost2 -Name $vm -RunAsync -Server $vcenter
	$num++
	[string]$vm = 'win7-' + $num
	New-VM -Datastore bnppDSC -VM Windows7 -VMHost $esxhost3 -Name $vm -RunAsync -Server $vcenter
	$num++
	# sleep 5 seems perfect for keeping 3-5 in que and none waiting. VAAI ops
	sleep 5
}

while((Get-Task -Server $vcenter -Status Running).name -like 'ApplyStorageDrsRecommendation_Task') {
write-host "Waiting for clones to complete.... sleeping 15 seconds" ; sleep 15 
}

[string]$timestamp = Get-Date -Format "dd-MMM-yyyy-hhmmss"
Write-Output '**Stop deploy clones ' $timestamp

$deployedvms = Get-VM -Datastore bnppDSC | Measure-Object -Line

Write-Output 'Clone calls made: ' $num
Write-Output 'Clones Completed: ' $deployedvms.lines

#check storge usage
C:\solidfire\scripts\sqd\bnppcheckUsage.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost

Stop-Transcript
Disconnect-SFCluster -Target $mvip
Disconnect-VIServer -Confirm:$false -Server $vcenter