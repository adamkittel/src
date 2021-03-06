
$vcenter = "192.168.129.144"
 Connect-VIServer -Server $vcenter -User admin -Password solidfire -Force -SaveCredentials
 Start-Transcript -Force -Path "vaai.unmap.log"
 
 $esxhost = "192.168.133.115"
 $cloneprefix = "clone"
 $datastore = "unmap"
 $num = 1
 
1..100 | foreach {
1..57 | foreach {
	Write-Host "Deploying $ClonePrefix$Num"
	New-VM -Datastore $datastore -VMHost $esxhost -VM ubuntuServer -Name $cloneprefix$num -RunAsync -Server $vcenter -Verbose
	$num++
}

Write-Host -ForegroundColor Cyan -BackgroundColor Black "Waiting for all clones to deploy"
while(Get-Task -Server $vcenter -Status Running) {
	$stats = Get-Task -Server $vcenter -Status Running
	Write-Host -ForegroundColor White -BackgroundColor Black "Tasks Running" $stats.Length
	sleep 30
}

$vms = Get-VM -Datastore unmap -Server $vcenter 
ForEach ($vm in $vms) {
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "Power on " $vm
	Start-VM -RunAsync -Server $vcenter -VM $vm -Verbose
	}

Write-Host -ForegroundColor Cyan -BackgroundColor Black "Waiting for all vm's to power on"
while(Get-Task -Server $vcenter -Status Running) {
	$stats = Get-Task -Server $vcenter -Status Running
	Write-Host -ForegroundColor White -BackgroundColor Black "Tasks Running" $stats.Length
	sleep 30
}

## Invoke-VMScript vdbench

ForEach ($vm in $vms) {
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "Suspend " $vm
	Suspend-VM -Confirm:$false -RunAsync -Server $vcenter -VM $vm -Verbose
}
	

Write-Host -ForegroundColor Cyan -BackgroundColor Black "Waiting for all vm's to suspend"
while(Get-Task -Server $vcenter -Status Running) {
	$stats = Get-Task -Server $vcenter -Status Running
	Write-Host -ForegroundColor White -BackgroundColor Black "Tasks Running" $stats.Length
	sleep 30
}


ForEach ($vm in $vms) {
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "Power on " $vm
	Start-VM -RunAsync -Server $vcenter -VM $vm -Verbose
}

Write-Host -ForegroundColor Cyan -BackgroundColor Black "Waiting for all vm's to power on"
while(Get-Task -Server $vcenter -Status Running) {
	$stats = Get-Task -Server $vcenter -Status Running
	Write-Host -ForegroundColor White -BackgroundColor Black "Tasks Running" $stats.Length
	sleep 30
}

# Invoke-VMScript check vdbench

ForEach ($vm in $vms) {
	$vmstat = Get-VM -Datastore unmap -Name $vm -Server $vcenter
	if( $vmstat.PowerState -eq 'PoweredOn' ) { 
		Write-Host -ForegroundColor Cyan -BackgroundColor Black "Power off " $vm
		Stop-VM -RunAsync -Server $vcenter -VM $vm -Confirm:$false
	}
}

Write-Host -ForegroundColor Cyan -BackgroundColor Black "Waiting for all vm's to power off"
while(Get-Task -Server $vcenter -Status Running) {
	$stats = Get-Task -Server $vcenter -Status Running
	Write-Host -ForegroundColor White -BackgroundColor Black "Tasks Running" $stats.Length
	sleep 30
}

ForEach ($vm in $vms) {
	$vmstate = Get-VM -Datastore unmap -Name $vm -Server $vcenter
	if( $vmstate.PowerState -eq 'PoweredOff' ) {
		Write-Host -ForegroundColor Cyan -BackgroundColor Black "Removing $vm from disk"
		Remove-VM -Confirm:$false -DeletePermanently -RunAsync -Server $vcenter -VM $vm
	}
}

Write-Host -ForegroundColor Cyan -BackgroundColor Black "Waiting for all vm's to be removed"
while(Get-Task -Server $vcenter -Status Running) {
	$stats = Get-Task -Server $vcenter -Status Running
	Write-Host -ForegroundColor White -BackgroundColor Black "Tasks Running" $stats.Length
	sleep 30
}
}

# check cluster