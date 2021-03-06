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
# 
## connect to vcenter. exit if fail
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

Write-Host "########## Start vSphere Setup ##########"
## set root folder
$location = Get-Folder -NoRecursion

## create datacenter. ignore error if exists. 
try {
New-Datacenter -ErrorAction Stop -Server $vcenter -Name "Datacenter" -Location $location -ErrorVariable $DCERR -Verbose
} catch { Write-Host -BackgroundColor Yellow -ForegroundColor Black  "Failed to add Datacenter. Exists?" }

## create cluster. do not enable ha or drs. ignore error if exists
try {
New-Cluster -ErrorAction Stop -Location "Datacenter" -Name "Cluster" -Server $vcenter -ErrorVariable $CLERR -Verbose
} catch { Write-Host -BackgroundColor Yellow -ForegroundColor Black "Failed to add Cluster. Exists?" }

## add esxi host. ignore error if exists. if in maint mode, set to connected
try {
Add-VMHost -ErrorAction Stop -ErrorVariable $ADDERR -Force -Location "Cluster" -Name $esxhost -Password $esxpass -Server $vcenter -User $esxadmin -Verbose
Get-VMHost -Name $esxhost -Server $vcenter -State Maintenance | Set-VMHost -State Connected -Verbose
#Write-Host -ForegroundColor Green -BackgroundColor Black (Out-String -InputObject $HOSTA.ConnectionState)
} catch { Write-Host  -BackgroundColor Yellow -ForegroundColor Black  "Host" $esxhost "Failed to add. Exists?" }


Write-Host "########## End vSphere Setup ##########"
Stop-Transcript 

	