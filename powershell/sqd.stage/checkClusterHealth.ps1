param(
	[string]$sfadmin='admin',
	[string]$sfpass='admin',
	[string]$mvip
)

c:\SQD\scripts\Initialize-SFEnvironment.ps1
###################################
# set up vcenter
# add datastore, cluster and host
#
# usage: vSphereSetup.ps1 
# -vcenter [name/ip] 
# -vcadmin [vcenter administrator (default: admin)] 
# -vcpass [vc adminsistrator password (default: solidfire)]
# -esxhost [name/ip]
# -esxadmin [esxi administrator (default: root)]
# -esxpass [esxi administrator password (default: solidfire)]
# start the run log

$rundate = Get-Date -Format "dd-MMM-yyyy"
$statfile = "c:\SQD\logs\checkClusterHealth.stat.log"
$checkfile = "c:\SQD\logs\checkClusterHealth.checklist.log"
$errwarn = "c:\SQD\logs\checkClusterHealth.errwarn.log"

Start-Transcript -Append -Force -NoClobber -Path "c:\SQD\logs\checkClusterHealth.transcript.log" 
# 
## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")" Start Check Cluster Health ##" 
$header | Tee-Object -Append -FilePath $checkfile

$sfversion = Get-SFClusterVersionInfo
[string]$msg = Write-Output "*Cluster Version: " $sfversion.ClusterVersion
$msg | Tee-Object -Append -FilePath $statfile

$sfadmins = Get-SFClusterAdmin
foreach ($admin in $sfadmins) {
	[string]$msg = Write-Output "*Cluster Admin: "$admin.UserName":"$admin.Access
	$msg | Tee-Object -Append -FilePath $statfile
}	

Write-Output "*Cluster capacity " | Tee-Object -Append -FilePath $statfile
Get-SFClusterCapacity | Tee-Object -Append -FilePath $statfile

Write-Output "*Cluster full threshold " | Tee-Object -Append -FilePath $statfile
Get-SFClusterFullThreshold | Tee-Object -Append -FilePath $statfile

Write-Output "*Cluster info " | Tee-Object -Append -FilePath $statfile
Get-SFClusterInfo | Tee-Object -Append -FilePath $statfile

Write-Output "*Cluster stats " | Tee-Object -Append -FilePath $statfile
Get-SFClusterStat | Tee-Object -Append -FilePath $statfile

Write-Output "*Cluster faults  " | Out-File -Append -FilePath $errwarn
$sffaults = Get-SFClusterFault
foreach ($sffault in $sffaults) {
		[string]$msg = Write-Output $sffault.Date":"$sffault.Severity":"$sffault.Code":"$sffault.Details
		$msg | Out-File -Append -FilePath $errwarn
}

Write-Output "*Cluster drive stats  " | Tee-Object -Append -FilePath $checkfile
$sfdrives = Get-SFDrive
foreach ($sfdrive in $sfdrives) {
	if($sfdrive.Status -eq 'active'){ 
		[string]$a = Write-Output "OK: Drive: " $sfdrive.DriveID "Slot: " $sfdrive.Slot "Drive status: " $sfdrive.Status
		$a | Tee-Object -Append -FilePath $checkfile
		} else{ 
		[string]$err = Write-Output "WARNING: Drive " $sfdrive.DriveID "Slot: " $sfdrive.Slot "Drive status: " $sfdrive.Status
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
}

Write-Output "*Cluster volume stats  " | Tee-Object -Append -FilePath $checkfile
$sfvols = Get-SFVolume
foreach ($sfvol in $sfvols) {
	if($sfvol.VolumeStatus -eq 'active'){ 
		[string]$a = Write-Output "OK: VolID: " $sfvol.VolumeID "Vol Name: " $sfvol.VolumeName "Vol status: " $sfvol.VolumeStatus
		$a | Tee-Object -Append -FilePath $checkfile
		} else{ 
		[string]$err = Write-Output "WARNING: Volume " $sfvol.VolumeName "Vol status: " $sfvol.VolumeStatus
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
}
	
[string]$footer = Write-Output "## "(Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") "End Check Cluster Health ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript
