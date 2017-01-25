param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$datastore, 
	[string]$powerop 
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("poweropVMbyDatastore.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start ESXi VM power operations by datastore ##" 
$header | Tee-Object -Append -FilePath $checkfile

[string]$msg = Write-Output "*Power operation all VM's on datstore: " $powerop $datastore 
$msg | Tee-Object -Append -FilePath $checkfile

$num = 1
$vms = Get-VM -Datastore $datastore -Server $vcenter

foreach ($vm in $vms) {
	switch ($powerop) {
		"SuspendVMGuest" {
		[string]$msg = Write-Output "*Suspend Guest: Cannot be run async: " $vm
		$header | Tee-Object -Append -FilePath $checkfile
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') { 
				Suspend-VMGuest -VM $vm -Server $vcenter -Confirm:$false
			}
		$powerstate = 'Suspended'
		}
		"ShutdownVMGuest" {
		[string]$msg = Write-Output "*Shutdown Guest: Cannot be run async: " $vm
		$header | Tee-Object -Append -FilePath $checkfile
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') { 
				Shutdown-VMGuest -VM $vm -Server $vcenter -Confirm:$false 
			}
		$powerstate = 'PoweredOff'
		}
		"RestartVMGuest" {
		[string]$msg = Write-Output "*Restart Guest: Cannot be run async: " $vm
		$header | Tee-Object -Append -FilePath $checkfile
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') { 
				Restart-VMGuest -VM $vm -Server $vcenter -Confirm:$false
			}
		$powerstate = 'PoweredOn'
		}
		"StartVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOn') 
			{ 
				Start-VM -VM $vm -Server $vcenter -Confirm:$false -RunAsync
			}			
		$powerstate = 'PoweredOn'
		}
		"StopVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') 
			{ 
				Stop-VM -VM $vm -Server $vcenter -Confirm:$false -RunAsync 
			}
			$powerstate = 'PoweredOff'
		}
		"SuspendVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') 
			{ 
				Suspend-VM -VM $vm -Server $vcenter -Confirm:$false -RunAsync
			}			
		$powerstate = 'Suspended'
		}
		"RestartVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') 
			{ 
				Restart-VM -VM $vm -Server $vcenter -Confirm:$false -RunAsync
			}			
		$powerstate = 'PoweredOn'
		}
		default { 
			Write-Host "*Specify power op: SuspendVMGuest ShutdownVMGuest RestartVMGuest StartVM SuspendVM RestartVM"
		}
	}
}

# wait for power op tasks to complete
while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for power op's to complete" ; sleep 20 }

<#
foreach ($vm in $vms) {
	$vmstate = Get-VM -Server $vcenter -Name $vm
	if ($vmstate.PowerState -eq $powerstate) {
		[string]$pass = Write-Output "PASS: VM power state: " $vmstate.PowerState $vm
		$pass | Tee-Object -Append -FilePath $checkfile	
		# help the poor VM's that ran out of swapfile space
		$vmmsg = Get-VMQuestion -Server $vcenter -VM $vm
		if ($vmmsg) { 
			Get-VMQuestion -Server $vcenter -VM $vm | Set-VMQuestion -Confirm:$false -Option button.abort
		}
	} else {
		[string]$err = Write-Output "FAIL: VM power state" $vmstate.PowerState $vm $vmmsg.Text
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
}
#>

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi VM power operations  by datastore ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
