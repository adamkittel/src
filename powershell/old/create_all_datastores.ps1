 param(
	[String]$vcenter='192.168.129.66',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost='192.168.133.115',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

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
Start-Transcript -Append -Force -NoClobber -Path "vSphereSetup.log" 

 Connect-VIServer -Server 172.26.254.246 -User administrator -Password solidfire

Write-Host -BackgroundColor Black -ForegroundColor White (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")" Start Create VMFS datastores ##########"
Get-VMHostStorage -vmHost $MyHost -RescanAllHba
$VOLS = Get-ScsiLun -VmHost $MyHost -CanonicalName "naa.6f47*"
$VolNum = 1

ForEach ($VolPath in $VOLS) {
	$DatastoreName = "vol"
	
	Write-Host "DS Name:  $DatastorePrefix$DatastoreName     -     LUN: $VolPath"
	New-Datastore -Vmfs -Name "$DatastorePrefix$DatastoreName$VolNum" -Path $VolPath -FileSystemVersion 5 -VMHost $MyHost
	$VolNum++
}
