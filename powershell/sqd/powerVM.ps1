param(
	[String]$vcenter='192.168.129.66',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost='192.168.133.115',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$linuxprefix='linux',
	[string]$windowsprefix='win',
	[string]$linuxvm='ubuntuServer',
	[string]$windowsvm='Windows7'
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
# -linuxprefix [datastore prefix (default: linux)]
# -windowsprefix [datastore prefix (default: windows)]
# -linuxvm [linux parent/template]
# -windowsvm [windows parent/template]


Start-Transcript -Append -Force -NoClobber -Path "powerVMs.log"
# 
## connect to vcenter. exit if fail
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

Write-Host "########## Start ESXi deploy vms ##########"

#boot storm by datastore cluster
$num = 1
$dscs = Get-DatastoreCluster -Server $vcenter

foreach ($dsc in $dscs)
{
	$vms = Get-VM -Datastore $dsc -Server $vcenter
	foreach ($vm in $vms) {
		$powerstate = Get-VM $vm
		if($powerstate.PowerState -eq 'PoweredOff') 
		{ 
			Start-VM -VM $vm -Server $vcenter -RunAsync
			Write-Host "power on" $vm
		}
	}
	while((Get-Task -Server $vcenter -Status Running))
		{
			Write-Host "Waiting for tasks to finish. Sleeping 10 seconds" 
			sleep 10
		}
}
		
	




Write-Host "########## Start ESXi deploy vms ##########"
Stop-Transcript 