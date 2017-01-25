param(
	[string]$sfadmin='admin',
	[string]$sfpass='admin',
	[Parameter(Mandatory=$true)]
	[string]$mvip
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

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

Write-Output "*Cluster drive stats  " | Tee-Object -Append -FilePath $statfile
$sfdrives = Get-SFDrive
foreach ($sfdrive in $sfdrives) {
	if($sfdrive.Status -eq 'active'){ 
		[string]$a = Write-Output "OK: Drive: " $sfdrive.DriveID "Slot: " $sfdrive.Slot "Drive status: " $sfdrive.Status
		$a | Tee-Object -Append -FilePath $statfile
		} else{ 
		[string]$err = Write-Output "WARNING: Drive " $sfdrive.DriveID "Slot: " $sfdrive.Slot "Drive status: " $sfdrive.Status
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
}

Write-Output "*Cluster volume stats  " | Tee-Object -Append -FilePath $statfile
$sfvols = Get-SFVolume
foreach ($sfvol in $sfvols) {
	if($sfvol.VolumeStatus -eq 'active'){ 
		[string]$a = Write-Output "OK: VolID: " $sfvol.VolumeID "Vol Name: " $sfvol.VolumeName "Vol status: " $sfvol.VolumeStatus
		$a | Tee-Object -Append -FilePath $statfile
		} else{ 
		[string]$err = Write-Output "WARNING: Volume " $sfvol.VolumeName "Vol status: " $sfvol.VolumeStatus
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
}
	
[string]$footer = Write-Output "## "(Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") "End Check Cluster Health ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
