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
#	[Parameter(Mandatory=$true)]
	[string]$vmprefix,
	[Parameter(Mandatory=$true)]
	[string]$powerop
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

#boot storm by datastore cluster
$num = 1
$vms = Get-VM  -Datastore '*default*'

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
			#$powerstate = Get-VM $vm
			#if($powerstate.PowerState -ne 'PoweredOn') { 
				Start-VM -VM $vm  -Confirm:$false -RunAsync
			#}			
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

while((Get-Task  -Status Running).name -eq 'PowerOnVM_Task') {
	write-host "Waiting for poweron to complete.... sleeping 3 seconds" ; sleep 3 
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi power operations by VM prefix ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
