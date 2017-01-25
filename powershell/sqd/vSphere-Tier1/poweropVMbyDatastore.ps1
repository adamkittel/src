param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$datastore, 
	[Parameter(Mandatory=$true)]
	[string]$powerop 
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript


[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

[string]$msg = Write-Output "*Power operation all VM's on datstore: " $powerop $datastore 
$msg | Tee-Object -Append -FilePath $statfile

$num = 1
$vms = Get-VM -Datastore $datastore 

foreach ($vm in $vms) {
	switch ($powerop) {
		"SuspendVMGuest" {
		[string]$msg = Write-Output "*Suspend Guest: Cannot be run async: " $vm
		$header | Tee-Object -Append -FilePath $statfile
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') { 
				Suspend-VMGuest -VM $vm  -Confirm:$false
			}
		$powerstate = 'Suspended'
		}
		"ShutdownVMGuest" {
		[string]$msg = Write-Output "*Shutdown Guest: Cannot be run async: " $vm
		$header | Tee-Object -Append -FilePath $statfile
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') { 
				Shutdown-VMGuest -VM $vm  -Confirm:$false 
			}
		$powerstate = 'PoweredOff'
		}
		"RestartVMGuest" {
		[string]$msg = Write-Output "*Restart Guest: Cannot be run async: " $vm
		$header | Tee-Object -Append -FilePath $statfile
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') { 
				Restart-VMGuest -VM $vm  -Confirm:$false
			}
		$powerstate = 'PoweredOn'
		}
		"StartVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOn') 
			{ 
				Start-VM -VM $vm  -Confirm:$false -RunAsync
			}			
		$powerstate = 'PoweredOn'
		}
		"StopVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') 
			{ 
				Stop-VM -VM $vm  -Confirm:$false -RunAsync 
			}
			$powerstate = 'PoweredOff'
		}
		"SuspendVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') 
			{ 
				Suspend-VM -VM $vm  -Confirm:$false -RunAsync
			}			
		$powerstate = 'Suspended'
		}
		"RestartVM" {
			$powerstate = Get-VM $vm
			if($powerstate.PowerState -ne 'PoweredOff') 
			{ 
				Restart-VM -VM $vm  -Confirm:$false -RunAsync
			}			
		$powerstate = 'PoweredOn'
		}
		default { 
			Write-Host "*Specify power op: SuspendVMGuest ShutdownVMGuest RestartVMGuest StartVM SuspendVM RestartVM"
		}
	}
}

# wait for power op tasks to complete
while(Get-Task  -Status Running) { write-host "Waiting for power op's to complete" ; sleep 20 }

<#
foreach ($vm in $vms) {
	$vmstate = Get-VM  -Name $vm
	if ($vmstate.PowerState -eq $powerstate) {
		[string]$pass = Write-Output "PASS: VM power state: " $vmstate.PowerState $vm
		$pass | Tee-Object -Append -FilePath $statfile	
		# help the poor VM's that ran out of swapfile space
		$vmmsg = Get-VMQuestion  -VM $vm
		if ($vmmsg) { 
			Get-VMQuestion  -VM $vm | Set-VMQuestion -Confirm:$false -Option button.abort
		}
	} else {
		[string]$err = Write-Output "FAIL: VM power state" $vmstate.PowerState $vm $vmmsg.Text
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
}
#>

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi VM power operations  by datastore ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
