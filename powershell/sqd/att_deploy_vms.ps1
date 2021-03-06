
 Connect-VIServer -Server 172.26.254.246 -User administrator -Password solidfire
 Start-Transcript -Force -Path "c:\Users\Administrator\attcloneNFSiops10.log"
 
 $MyHost = "172.26.201.51"
 $ClonePrefix = "iops10ATTnfs"
 $Datastore = "ATTvol"
 $Num = 1
 
1..8 | foreach {
	Write-Host "Deploying $ClonePrefix$Num"
	New-VM -Datastore $Datastore$Num -VMHost $MyHost -VM attvmNFS -Name $ClonePrefix$Num -RunAsync -Server 172.26.254.246
	$Num++
}

Stop-Transcript 