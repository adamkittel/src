param(
	[string]$sfadmin='admin',
	[string]$sfpass='admin',
	[string]$mvip
)

c:\SQD\scripts\Initialize-SFEnvironment.ps1
## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")" Start Check Cluster Health ##" 
$header

$sfversion = Get-SFClusterVersionInfo
[string]$msg = Write-Output "*Cluster Version: " $sfversion.ClusterVersion
$msg 

$sfadmins = Get-SFClusterAdmin
foreach ($admin in $sfadmins) {
	[string]$msg = Write-Output "*Cluster Admin: "$admin.UserName":"$admin.Access
	$msg 
}	

Write-Output "*Cluster capacity " 
Get-SFClusterCapacity

Write-Output "*Cluster full threshold "
Get-SFClusterFullThreshold 

Write-Output "*Cluster info " 
Get-SFClusterInfo 

Write-Output "*Cluster stats " 
Get-SFClusterStat 

Write-Output "*Cluster faults  " 
$sffaults = Get-SFClusterFault
foreach ($sffault in $sffaults) {
		[string]$msg = Write-Output $sffault.Date":"$sffault.Severity":"$sffault.Code":"$sffault.Details
		$msg 
}

Write-Output "*Cluster drive stats  " 
$sfdrives = Get-SFDrive
foreach ($sfdrive in $sfdrives) {
	if($sfdrive.Status -eq 'active'){ 
		[string]$a = Write-Output "OK: Drive: " $sfdrive.DriveID "Slot: " $sfdrive.Slot "Drive status: " $sfdrive.Status
		$a 
		} else{ 
		[string]$err = Write-Output "WARNING: Drive " $sfdrive.DriveID "Slot: " $sfdrive.Slot "Drive status: " $sfdrive.Status
		$err
	}
}

Write-Output "*Cluster volume stats  "
$sfvols = Get-SFVolume
foreach ($sfvol in $sfvols) {
	if($sfvol.VolumeStatus -eq 'active'){ 
		[string]$a = Write-Output "OK: VolID: " $sfvol.VolumeID "Vol Name: " $sfvol.VolumeName "Vol status: " $sfvol.VolumeStatus
		$a 
		} else{ 
		[string]$err = Write-Output "WARNING: Volume " $sfvol.VolumeName "Vol status: " $sfvol.VolumeStatus
		$err 
	}
}
	
[string]$footer = Write-Output "## "(Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") "End Check Cluster Health ##" 
$footer 
