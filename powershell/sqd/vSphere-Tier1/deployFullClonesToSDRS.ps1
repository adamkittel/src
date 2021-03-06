param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='ubuntuServer',
	[string]$windowsvm='Windows7',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

$num = 1
$dsc = Get-DatastoreCluster -Server $vcenter -Name '*default*'

1..10 | foreach {
	$vm = $hostprefix + $clustername + 'Fullubuntu' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		New-VM -Datastore $dsc -VMHost $esxhost -VM $linuxvm -Name $vm -RunAsync -Server $vcenter
	}
	$vm = $hostprefix + $clustername + 'Fullwindows' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		New-VM -Datastore $dsc -VMHost $esxhost -VM $windowsvm -Name $vm -RunAsync -Server $vcenter
	}
	$num++
	while((Get-Task -Server $vcenter -Status Running).name -like 'ApplyStorageDrsRecommendation_Task') {
		write-host "Waiting for clones to complete.... sleeping 15 seconds" ; sleep 15 
	}
}

$vmcount = Get-VM -Name '*Full*' -Server $vcenter | Measure-Object -Line
[string]$pass = Write-Output "PASS: Linked clones created: " $vmcount.Lines
$pass | Tee-Object -Append -FilePath $statfile 

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy SDRS Clones ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
