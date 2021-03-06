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
# add params for vol prefix, datastore prefix, 
# init powercli and SF powershell environments
#.\Initialize-PowerCLIEnvironment.ps1
#.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$scriptname = $myinvocation.MyCommand.Name
. c:\solidfire\scripts\BootStorm\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost

Start-Transcript -Append -Force -NoClobber -Path $transcript

Write-Output "*Rescan adapters"
Get-VMHostStorage -vmHost $esxhost -RescanAllHba -Server $vcenter

Write-Output "*Create default QoS value datastores with SIOC enabled"

$volnum = 1
$vols = Get-SFVolume -VolumeName 'bnpp*'
foreach ($vol in $vols) {
	[string]$volname = 'bnpp-' + $volnum
	$volpath = 'naa.' + $vol.Scsi_NAA_DeviceID
	$dstore = New-Datastore -Vmfs -Name $volname -Path $volpath -FileSystemVersion 5 -VMHost $esxhost -Server $vcenter
	Set-Datastore -StorageIOControlEnabled $true -Datastore $volname -Server $vcenter
	$volnum++
}
	
Stop-Transcript
Disconnect-SFCluster -Target $mvip
Disconnect-VIServer -Confirm:$false -Server $vcenter

