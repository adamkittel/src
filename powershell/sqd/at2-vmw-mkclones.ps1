param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='ubuntuServer',
	[string]$windowsvm='ADserver',
	[String]$vcenter='172.26.254.246',
	[String]$vcadmin='administrator',
	[String]$vcpass='solidfire',
	[string]$esxhost='172.26.254.42',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$dsname
)

.\Initialize-SFEnvironment.ps1
.\Initialize-PowerCLIEnvironment.ps1

## connect. exit if fail
#Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$linuxvm = 'esx-ubuntu-gold-01current_template'
$num = 37

37..100 | foreach {
	[string]$vm = 'esx-idle-000' + $num
	[string]$dsname = 'esx-idle-000' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
	} else {
		New-VM -Datastore $dsname -VMHost $esxhost -VM $linuxvm -Name $vm -Server $vcenter
	}
	$num++
}
