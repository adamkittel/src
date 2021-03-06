param(
	#[Parameter(Mandatory=$true)]
	[string]$vcenter = '192.168.129.228',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$esxhost = '172.24.67.3',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$dsname = 'HostIntInfra',
	[Parameter(Mandatory=$true)]
	[string]$prefix,
	[Parameter(Mandatory=$true)]
	[string]$location,
	[Parameter(Mandatory=$true)]
	[string]$snapname 
)


.\Initialize-PowerCLIEnvironment.ps1

Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials
$vms = Get-VM -Location $location -Name $prefix*
foreach ($vm in $vms) {
	if( $vm.powerstate -eq 'PoweredOn' ) {
		[string]$msg = "Shutting Down: " + $vm 
		Write-Output $msg
		Shutdown-VMGuest -Confirm:$false -VM $vm
		sleep 30
		while ((Get-VM -Name $vm).PowerState -ne 'PoweredOff') {
			sleep 60
			Write-Output "Waiting for shutdown.......zzzzzzz"
		}
	}
}

foreach ($vm in $vms) {
	[string]$msg = "Taking Snapshot: " + $vm
	Write-Output $msg
	New-Snapshot -Confirm:$false -Name $snapname -VM $vm
	Start-VM -Confirm:$false -VM $vm
}

Disconnect-VIServer -Confirm:$false

