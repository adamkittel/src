 Connect-VIServer -Server 172.26.254.246 -User administrator -Password solidfire

 $MyHost = "172.26.201.51"
 $DatastorePrefix = "ATT"
  
Get-VMHostStorage -vmHost $MyHost -RescanAllHba
$VOLS = Get-ScsiLun -VmHost $MyHost -CanonicalName "naa.6f47*"
$VolNum = 1

ForEach ($VolPath in $VOLS) {
	$DatastoreName = "vol"
	
	Write-Host "DS Name:  $DatastorePrefix$DatastoreName     -     LUN: $VolPath"
	New-Datastore -Vmfs -Name "$DatastorePrefix$DatastoreName$VolNum" -Path $VolPath -FileSystemVersion 5 -VMHost $MyHost
	$VolNum++
}
