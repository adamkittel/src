param(
	#[Parameter(Mandatory=$true)]
	[string]$vcenter = '192.168.129.228',
	[String]$vcadmin='administrator@solidfire.eng',
	[String]$vcpass='solidF!r3',
	#[Parameter(Mandatory=$true)]
	[string]$esxhost = '192.168.133.126',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$dsname = 'HostIntInfra',
	[Parameter(Mandatory=$true)]
	[string]$vcname,
	[Parameter(Mandatory=$true)]
	[string]$esxvm
)

.\Initialize-PowerCLIEnvironment.ps1

Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# deploy vcsa6
# Convert JSON file to PowerShell object 
$vcsa6config = 'c:\solidfire\conf\6.0-vSphereDeploy.json'
$deploy = "C:\vcsa6\vcsa-cli-installer\win32\vcsa-deploy.exe"
$UpdatedConfig = "c:\solidfire\conf\TempHostInt.json"
$config = (Get-Content -Raw $vcsa6config) | ConvertFrom-Json
 
 <#
# vCSA system information
$config.vcsa.system."root.password"=$esxpass
$config.vcsa.system."ntp.servers"="us.pool.ntp.org"
$config.vcsa.sso.password=$vcpass
$config.vcsa.sso."site-name" = "Main-Site"
 
# ESXi Host Information
$config.deployment."esx.hostname"=$esxhost
$config.deployment."esx.datastore"=$dsname
$config.deployment."esx.username"=$esxadmin
$config.deployment."esx.password"=$esxpass
$config.deployment."deployment.option"="tiny"
$config.deployment."deployment.network"="VM Network"
$config.deployment."appliance.name"=$vcname
 #>
$config.deployment."appliance.name"=$vcname
# Database connection
#$config.vcsa.database.type="embedded"
#
 
# Networking
$config.vcsa.networking.mode = "dhcp"
#$config.vcsa.networking.ip = "10.144.99.27"
#$config.vcsa.networking.prefix = "24"
#$config.vcsa.networking.gateway = "10.144.99.1"
#$config.vcsa.networking."dns.servers"="10.144.99.5"
#$config.vcsa.networking."system.name"="10.144.99.27"
$config | ConvertTo-Json | Set-Content -Path "$UpdatedConfig"
iex "$deploy $UpdatedConfig"
 
# deploy esxi vm
New-VM -Confirm:$false -Datastore $dsname -VM 'esxTemplate' -Name $esxvm -VMHost $esxhost
Set-CDDrive -CD (Get-CDDrive -vm $esxvm) -IsoPath "[HostIntInfra]\6.0-vm.iso" -StartConnected 1 -Confirm:$false
Start-VM -Confirm:$false -VM $esxvm -RunAsync

Disconnect-VIServer -Confirm:$false

