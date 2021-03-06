Connect-VIServer -Server 192.168.129.144 -User admin -Password solidfire
 #Start-Transcript -Force -Path "c:\Users\Administrator\attcloneNFSiops10.log"
 $vcenter = "192.168.129.144"
 $MyHost = "192.168.133.126"
 $ClonePrefix = "vm"
 $Datastore = "unmap"
 $Num = 1
<# 
1..30 | foreach {
	Write-Host "Deploying $ClonePrefix$Num"
	New-VM -Datastore $Datastore$Num -VMHost $MyHost -VM ATTvmJeff -Name $ClonePrefix$Num -RunAsync -Server 172.26.254.246
	$Num++
}
#>

#Customizations
$CsvPath = "C:TempIQN-Export.csv"
 
#Variables
$ESXiHosts = Get-VMHost -Server $vcenter | Sort-Object
 
foreach ($ESXiHost in $ESXiHosts)
{
$h = Get-VMhost -Server $vcenter $ESXiHost.Name
Write-Host "Getting IQN for $h"
$hostview = Get-View -Server $vcenter $h.id
$storage = Get-View -Server $vcenter $hostview.ConfigManager.StorageSystem
Write-Host  $storage.StorageDeviceInfo.HostBusAdapter.iScsiName
}
<#
$a = [PSCustomObject]@{
Hostname = $h.Name
IQN = $storage.StorageDeviceInfo.HostBusAdapter.iScsiName
}
$a | Export-CSV -Path $CsvPath -Append
}
Write-Host "CSV exported to $CsvPath"
#>