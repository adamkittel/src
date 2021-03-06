param(
	
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='ubuntuServer',
	[string]$windowsvm='Windows7',
	[string]$linuxparent='ubuntuParent',
	[string]$windowsparent='Windows7Parent',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
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
$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Deploy Linked Clones ##" 
$header | Tee-Object -Append -FilePath $checkfile

## max vm's is 512
## deploy XX vm's per datastore cluster
$num = 1
$dscs = Get-DatastoreCluster -Server $vcenter
$ubuntuSnap = Get-Snapshot -Server $vcenter -vm ubuntuParent
$windows7Snap = Get-Snapshot -Server $vcenter -vm windows7Parent
$dstores = Get-Datastore -Server $vcenter -Name 'linked*'

foreach ($dstore in $dstores)
{
	1..10 | foreach {
		1..2 | foreach {
			if(Get-VM -Name Linkedubuntu$num -Server $vcenter) {
				[string]$pass = Write-Output "PASS: VM already exists" Linkedubuntu$num
				$pass | Tee-Object -Append -FilePath $checkfile 
			} else {
				New-VM -Datastore $dstore -LinkedClone -ReferenceSnapshot $ubuntuSnap.Name -VM ubuntuParent -VMHost $esxhost -Name Linkedubuntu$num -RunAsync -Server $vcenter
			}
			if(Get-VM -Name Linkedwindows7$num -Server $vcenter) {
				[string]$pass = Write-Output "PASS: VM already exists" Linkedwindows7$num
				$pass | Tee-Object -Append -FilePath $checkfile 
			} else {
				New-VM -Datastore $dstore -LinkedClone -ReferenceSnapshot $windows7Snap.Name -VM windows7Parent -VMHost $esxhost -Name Linkedwindows7$num -RunAsync -Server $vcenter
			}
				$num++
			}
		while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for 8 clones to complete" ; sleep 30 }
	}	
	$vmcount = Get-VM -Datastore $dstore -Server $vcenter | Measure-Object -Line
	[string]$pass = Write-Output "PASS: Linked clones created: " $vmcount.Lines
	$pass | Tee-Object -Append -FilePath $checkfile 
}



[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy Linked Clones ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 