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

# init powercli and SF powershell environments
#.\Initialize-PowerCLIEnvironment.ps1
#.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

. c:\solidfire\scripts\BootStorm\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost

Start-Transcript -Append -Force -NoClobber -Path $transcript

Write-Output '** Rescan hba'
Get-VMHostStorage -RescanAllHba -VMHost $esxhost

# get all SF volumes not using $psp
$vols = Get-ScsiLun -CanonicalName '*6f47*' -VmHost $esxhost -Server $vcenter
#$vols = Get-SFVolumeForAccount -Accountid 1
$num = 1
foreach ($vol in $vols) {
	$newpsp = Set-ScsiLun -MultipathPolicy RoundRobin -Confirm:$false -ScsiLun $vol
	[string]$msg = $newpsp.CanonicalName + 'Set to ' + $newpsp.MultipathPolicy
	 Write-Output $msg
	$num++
}
		
Write-Output "*Rescan adapters"
Get-VMHostStorage -RescanAllHba -VMHost $esxhost

Disconnect-SFCluster -Target $mvip
Disconnect-VIServer -Confirm:$false -Server $vcenter
