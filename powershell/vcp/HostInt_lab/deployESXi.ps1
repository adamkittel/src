param(
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
	[string]$esxvm,
	[Parameter(Mandatory=$true)]
	[string]$version #5.1, 5.5, 6.0
)

.\Initialize-PowerCLIEnvironment.ps1

Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# set iso file
$iso = '[HostIntInfra]' + $version + '-vm.iso'
 # deploy esxi vm
New-VM -Confirm:$false -Datastore $dsname -VM 'esxTemplate' -Name $esxvm -VMHost $esxhost
Set-CDDrive -CD (Get-CDDrive -vm $esxvm) -IsoPath $iso -StartConnected 1 -Confirm:$false
Start-VM -Confirm:$false -VM $esxvm -RunAsync
