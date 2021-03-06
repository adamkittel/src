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
	[string]$esxvm,
#	[Parameter(Mandatory=$true)]
	[string]$snapname = 'Gold'
)

.\Initialize-PowerCLIEnvironment.ps1

Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$msg = "Shutting Down " + $esxvm + ' and ' + $esxvm
Write-Output $msg
Shutdown-VMGuest -Confirm:$false -VM $vcname
Shutdown-VMGuest -Confirm:$false -VM $esxvm

[string]$msg = "Wait for vcsa to shutdown"
Write-Output $msg
while ((Get-VM -Name $vcname).PowerState -ne 'PoweredOff') {
	sleep 60
	Write-Output "zzzzzzz"
}

[string]$msg = "Taking Snapshots"
Write-Output $msg
Set-VM -Confirm:$false -Snapshot $snapname -VM $vcname
Set-VM -Confirm:$false -Snapshot $snapname -VM $esxvm

[string]$msg = "Starting " + $esxvm + ' and ' + $esxvm
Start-VM -Confirm:$false -RunAsync -VM $vcname
Start-VM -Confirm:$false -RunAsync -VM $esxvm

Disconnect-VIServer -Confirm:$false

