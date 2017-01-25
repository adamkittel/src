﻿param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$maxprefix='max',
	[string]$minprefix='min',
	[string]$defprefix='def',
	[string]$rdmprefix='rdm',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$vmprefix,
	[string]$powerop
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("poweropVMbyPrefix.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start ESXi power operations by VM prefix ##" 
$header | Tee-Object -Append -FilePath $checkfile

#boot storm by datastore cluster
$num = 1
$vms = Get-VM -Server $vcenter

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
			if($powerstate.PowerState -ne 'PoweredOn') { 
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

while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for power op's to complete" ; sleep 20 }

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi power operations by VM prefix ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
