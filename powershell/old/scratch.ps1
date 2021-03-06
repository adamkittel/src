<#param([string]$VCENTER,[string]$ADMIN="admin",[String]$PASS)
if(param[String[]] -eg '-h') {
Write-Host "usage -vcenter -admin -password"
} 
#>

Connect-VIServer -Server 192.168.129.144 -User admin -Password solidfire -Force
Connect-SFCluster -Target 192.168.139.165 -UserName admin

Get-SFClusterCapacity -Verbose


#New-DatastoreCluster -Name ATTDSCluster -Location Datacenter
#Set-DatastoreCluster -DatastoreCluster ATTDSCluster -SdrsAutomationLevel FullyAutomated -IOLoadBalanceEnabled $true -SpaceUtilizationThresholdPercent 50
#Get-Datastore -Name "ATTvol*" | Move-Datastore -Destination ATTDSCluster
#$MyHost = "192.168.133.115"

<#
New-VM -Datastore vol2 -VMHost $MyHost -VM Windows7 -Name w4 -RunAsync 
$runningTasks = (Get-Task -Status Running)

while($runningTasks -gt 0){
	#if($taskTab.ContainsKey -eq "Success"){ 
	$task = ($_|Get-Task -Id)
	Write-Host $task "Running"
	sleep 30
}
#>

#Write-Host -BackgroundColor black -ForegroundColor white "$taskTab.Count" $taskTab.ContainsKey $taskTab.get_Values $taskTab.GetObjectData $taskTab.ToString $taskTab.Values

#Write-Host -ForegroundColor white -BackgroundColor Black $VCENTER $ADMIN $PASS
#Get-VirtualSwitch -Standard -Verbose 



<#
$MyHost = "192.168.133.115"
$ClonePrefix = "sqd"
$DCS = "ATTDSCluster"
$Num = 81
 
81..100 | foreach {
	Write-Host "Deploying $ClonePrefix$Num"
	New-VM -Datastore $DCS -VMHost $MyHost -VM Windows7 -Name $ClonePrefix$Num -RunAsync
	$Num++
}
#>