param(
	[String]$vcenter='192.168.129.66',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost='192.168.133.115',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$dsprefix='solidfire'
)

###################################
# set up networking for iscsi
# set up software iscsi adapter
#
# usage: .ps1 
# -vcenter [name/ip] 
# -vcadmin [vcenter administrator (default: admin)] 
# -vcpass [vc adminsistrator password (default: solidfire)]
# -esxhost [name/ip]
# -esxadmin [esxi administrator (default: root)]
# -esxpass [esxi administrator password (default: solidfire)]
# -dsprefix [datastore prefix (default: solidfire)]


Start-Transcript -Append -Force -NoClobber -Path "createDatastoreDatastoreCluster.log" 
# 
## connect to vcenter. exit if fail
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

Write-Host "########## Start ESXi create datstores and datstore clusters ##########"

Get-VMHostStorage -vmHost $esxhost -RescanAllHba -Server $vcenter
$vols = Get-ScsiLun -VmHost $esxhost -CanonicalName "naa.6f47*" -Server $vcenter
$volnum = 1

ForEach ($volpath in $vols) {
	try {
		New-Datastore -Vmfs -Name $dsprefix$volnum -Path $volpath -FileSystemVersion 5 -VMHost $esxhost -Verbose -Server $vcenter
		} catch { Write-Host -BackgroundColor Yellow -ForegroundColor Black "Failed to create " $dsprefix$volnum }
	$volnum++
}

$dc = "SFdatacenter"
$dscdefault = "DSCdefault"
$dscmin = "DSCmin"
$dscmax = "DSCmax"
# create datastore cluster with default values
try {
	New-DatastoreCluster -Location $dc -Name $dscdefault -Verbose -Server $vcenter
	Set-DatastoreCluster -DatastoreCluster $dscdefault -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated -Verbose -Server $vcenter
	} catch { Write-Host -BackgroundColor Yellow -ForegroundColor Black "Failed to create DSCfafault" }
	
# create datastore cluster with minimum values
try {
	New-DatastoreCluster -Location $dc -Name $dscmin -Verbose -Server $vcenter
	Set-DatastoreCluster -DatastoreCluster $dscmin -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated -Verbose -IOLatencyThresholdMillisecond 5 -SpaceUtilizationThresholdPercent 50 -Server $vcenter
	} catch { Write-Host -BackgroundColor Yellow -ForegroundColor Black "Failed to create DSCmax" }

# create datastore cluster with minimum values
try {
	New-DatastoreCluster -Location $dc -Name $dscmax -Verbose -Server $vcenter
	Set-DatastoreCluster -DatastoreCluster $dscmax -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated -Verbose -IOLatencyThresholdMillisecond 100 -SpaceUtilizationThresholdPercent 100 -Server $vcenter
	} catch { Write-Host -BackgroundColor Yellow -ForegroundColor Black "Failed to create DSCmin" }

$num =1
# move datastores into clusters
1..2| foreach {
	Get-Datastore -Name solidfire$num | Move-Datastore -Destination $dscdefault -Server $vcenter
	$num++
}

3..4| foreach {
	Get-Datastore -Name solidfire$num | Move-Datastore -Destination $dscmin -Server $vcenter
	$num++
}

5..6| foreach {
	Get-Datastore -Name solidfire$num | Move-Datastore -Destination $dscmax -Server $vcenter
	$num++
}


Write-Host "########## Start ESXi create datstores and datstore clusters ##########"
Stop-Transcript 