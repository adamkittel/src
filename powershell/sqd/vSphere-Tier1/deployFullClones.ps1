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
	[string]$esxpass='solidfire'
	[Parameter(Mandatory=$true)]
	[string]$dsname
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Deploy Full Clones ##" 
$header | Tee-Object -Append -FilePath $statfile


$num = 1

1..5 | foreach {
	[string]$vm = 'Fullubuntu' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		New-VM -Datastore $dsname -VMHost $esxhost -Template $linuxvm -Name $vm -RunAsync -Server $vcenter
	}
	[string]$vm = 'Fullwindows' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		New-VM -Datastore $dsname -VMHost $esxhost -Template $windowsvm -Name $vm -RunAsync -Server $vcenter
	}
	$num++
}

while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for clones to complete" ; sleep 30 }

$vmcount = Get-VM -Name 'Full*' -Server $vcenter | Measure-Object -Line
if($vmcount) {
	[string]$pass = Write-Output "PASS: Full clones created: " $vmcount.Lines
	$pass | Tee-Object -Append -FilePath $statfile 
} else {
	[string]$err = Write-Output "FAIL: No VM created"
	$err | Tee-Object -Append -FilePath $errwarn 
	$err | Out-File -Append -FilePath $statfile
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy Full Clones ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
