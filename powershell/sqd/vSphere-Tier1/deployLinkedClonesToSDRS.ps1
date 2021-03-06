param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxparent='ubuntuparent',
	[string]$windowparent='windowsparent',
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
$dscs = Get-DatastoreCluster -Server $vcenter
$ubuntuSnap = Get-Snapshot -Server $vcenter -vm $linuxparent
$windowsSnap = Get-Snapshot -Server $vcenter -vm $windowsparent

foreach ($dsc in $dscs)
{
	1..5 | foreach {
		[string]$vm = $hostprefix + $clustername + 'Linkedubuntu' + $num
		if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
			[string]$pass = Write-Output "PASS: VM already exists" $vm
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			New-VM -Datastore $dsc -LinkedClone -ReferenceSnapshot $ubuntuSnap.Name -VM $linuxparent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
		}
		[string]$vm = $hostprefix + $clustername + 'Linkedwindows' + $num
		if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
			[string]$pass = Write-Output "PASS: VM already exists" $vm
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			New-VM -Datastore $dsc -LinkedClone -ReferenceSnapshot $ubuntuSnap.Name -VM $windowsparent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
		}
		$num++
	}
}

while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for clones to complete" ; sleep 30 }
$vmcount = Get-VM -Name 'Full*' -Server $vcenter | Measure-Object -Line
[string]$pass = Write-Output "PASS: Linked clones created: " $vmcount.Lines
$pass | Tee-Object -Append -FilePath $statfile 

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy SDRS Clones ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
