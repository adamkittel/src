param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxparent='ubuntuparent',
	[string]$windowparent='windowsparent',
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

logSetup("deployLinkedClonesToSDRS.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

$clustername = ((Get-SFClusterInfo).name.split('-')[0])
# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Deploy SDRS Clones To SDRS Clusters ##" 
$header | Tee-Object -Append -FilePath $checkfile

$num = 1
$dscs = Get-DatastoreCluster -Server $vcenter
$ubuntuSnap = Get-Snapshot -Server $vcenter -vm $linuxparent
$windowsSnap = Get-Snapshot -Server $vcenter -vm $windowsparent

foreach ($dsc in $dscs)
{
	1..5 | foreach {
		[string]$vm = $clustername + 'Linkedubuntu' + $num
		if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
			[string]$pass = Write-Output "PASS: VM already exists" $vm
			$pass | Tee-Object -Append -FilePath $checkfile 
		} else {
			New-VM -Datastore $dsc -LinkedClone -ReferenceSnapshot $ubuntuSnap.Name -VM $linuxparent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
		}
		[string]$vm = $clustername + 'Linkedwindows' + $num
		if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
			[string]$pass = Write-Output "PASS: VM already exists" $vm
			$pass | Tee-Object -Append -FilePath $checkfile 
		} else {
			New-VM -Datastore $dsc -LinkedClone -ReferenceSnapshot $ubuntuSnap.Name -VM $windowsparent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
		}
		$num++
	}
}

while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for clones to complete" ; sleep 30 }
$vmcount = Get-VM -Name 'Full*' -Server $vcenter | Measure-Object -Line
[string]$pass = Write-Output "PASS: Linked clones created: " $vmcount.Lines
$pass | Tee-Object -Append -FilePath $checkfile 

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy SDRS Clones ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
