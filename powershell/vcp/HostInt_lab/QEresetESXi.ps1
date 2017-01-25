param (
    #[Parameter(Mandatory=$true)]
	[String]$vcenter='172.24.89.120',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
    #[Parameter(Mandatory=$true)]
	[string]$esxhost1='172.24.89.92',
	[string]$location1="SFdatacenter",
    #[Parameter(Mandatory=$true)]
	[string]$esxhost2='172.24.89.128',
	[string]$location2="SFcluster1",
    #[Parameter(Mandatory=$true)]
	[string]$esxhost3='172.24.89.129',
	[string]$location3="SFcluster2",
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

.\Initialize-PowerCLIEnvironment.ps1
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# reset ESXi hosts after vcenter snap revert
write-host -foregroundcolor green -backgroundcolor black "Set Hosts to maintenance mode"
get-vmhost -server $vcenter | set-vmhost -state Maintenance -confirm:$false

# remove esxi hosts
write-host -foregroundcolor green -backgroundcolor black "Remove ESXi hosts"
get-vmhost -server $vcenter | remove-vmhost -confirm:$false

sleep 10

# re-add ESXi hosts
write-host -foregroundcolor green -backgroundcolor black "Re-add ESXi hosts"
Add-VMHost -Force -Location $location1 -Server $vcenter -Name $esxhost1 -Password $esxpass -User $esxadmin
Add-VMHost -Force -Location $location2 -Server $vcenter -Name $esxhost2 -Password $esxpass -User $esxadmin
Add-VMHost -Force -Location $location3 -Server $vcenter -Name $esxhost3 -Password $esxpass -User $esxadmin

# exit maint mode
write-host -foregroundcolor green -backgroundcolor black "Exit Maintenance mode"
get-vmhost -server $vcenter | set-vmhost -state Connected -confirm:$false