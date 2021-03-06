
$vcenter = "192.168.129.144"
 Connect-VIServer -Server $vcenter -User admin -Password solidfire -Force -SaveCredentials
 Start-Transcript -Force -Path "vaai.unmap.log"
 
 $esxhost = "192.168.133.115"
 $cloneprefix = "clone"
 $datastore = "unmap"

# create linked clone script 
1..100 | foreach {
 $num = 1
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
$deploy = Get-VIEvent -Server $vcenter -Types error
$deploy.FullFormattedMessage | Format-List

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
$poweron = Get-VIEvent -Server $vcenter -Types error
if($poweron.Length -ne $deploy.Length) { $poweron.FullFormattedMessage | Format-List }

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
$suspend = Get-VIEvent -Server $vcenter -Types error
if($suspend.Length -ne $poweron.Length) { $suspend.FullFormattedMessage | Format-List }

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
$poweron = Get-VIEvent -Server $vcenter -Types error
if($poweron.Length -ne $suspend.Length) { $poweron.FullFormattedMessage | Format-List }


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
$poweroff = Get-VIEvent -Server $vcenter -Types error
if($poweroff.Length -ne $poweron.Length) { $poweroff.FullFormattedMessage | Format-List }

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
$remove = Get-VIEvent -Server $vcenter -Types error
if($remove.Length -ne $poweroff.Length) { $remove.FullFormattedMessage | Format-List }

}
# check cluster