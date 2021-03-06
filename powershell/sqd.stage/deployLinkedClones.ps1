param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='ubuntuServer',
	[string]$windowsvm='ADserver',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$linuxparent='ubuntuparent',
	[string]$windowsparent='windowsparent'
	[string]$dsname 
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("deployLinkedClones.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Deploy Linked Clones ##" 
$header | Tee-Object -Append -FilePath $checkfile

## max vm's is 512
## deploy XX vm's per datastore cluster
$num = 1
$ubuntuSnap = Get-Snapshot -Server $vcenter -vm $linuxparent
$windowsSnap = Get-Snapshot -Server $vcenter -vm $windowsparent

1..5 | foreach {
	[string]$vm = 'Linkedubuntu' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		New-VM -Datastore $dsname -LinkedClone -ReferenceSnapshot $ubuntuSnap.Name -VM ubuntuParent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
	}
	[string]$vm = 'Linkedwindows' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		New-VM -Datastore $dsname -LinkedClone -ReferenceSnapshot $windowsSnap.Name -VM windows7Parent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
	}
	$num++
}	

while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for clones to complete" ; sleep 30 }
$vmcount = Get-VM -Name 'Linked*' -Server $vcenter | Measure-Object -Line
[string]$pass = Write-Output "PASS: Linked clones created: " $vmcount.Lines
$pass | Tee-Object -Append -FilePath $checkfile 

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy Linked Clones ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
