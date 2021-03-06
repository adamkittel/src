param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='ubuntuServer',
	[string]$windowsvm='ADserver',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$linuxparent='ubuntuparent',
	[string]$windowsparent='windowsparent'
	[Parameter(Mandatory=$true)]
	[string]$dsname 
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Deploy Linked Clones ##" 
$header | Tee-Object -Append -FilePath $statfile

## max vm's is 512
## deploy XX vm's per datastore cluster
$num = 1
$ubuntuSnap = Get-Snapshot -Server $vcenter -vm $linuxparent
$windowsSnap = Get-Snapshot -Server $vcenter -vm $windowsparent

1..5 | foreach {
	[string]$vm = 'Linkedubuntu' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		New-VM -Datastore $dsname -LinkedClone -ReferenceSnapshot $ubuntuSnap.Name -VM ubuntuParent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
	}
	[string]$vm = 'Linkedwindows' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		New-VM -Datastore $dsname -LinkedClone -ReferenceSnapshot $windowsSnap.Name -VM windows7Parent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter
	}
	$num++
}	

while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for clones to complete" ; sleep 30 }
$vmcount = Get-VM -Name 'Linked*' -Server $vcenter | Measure-Object -Line
[string]$pass = Write-Output "PASS: Linked clones created: " $vmcount.Lines
$pass | Tee-Object -Append -FilePath $statfile 

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy Linked Clones ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
