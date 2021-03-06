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
	[string]$esxpass='solidfire'
	[string]$dsname
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("deployFullClones.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Deploy Full Clones ##" 
$header | Tee-Object -Append -FilePath $checkfile

$num = 1

1..5 | foreach {
	[string]$vm = 'Fullubuntu' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		New-VM -Datastore $dsname -VMHost $esxhost -Template $linuxvm -Name $vm -RunAsync -Server $vcenter
	}
	[string]$vm = 'Fullwindows' + $num
	if(Get-VM -Name $vm -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: VM already exists" $vm
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		New-VM -Datastore $dsname -VMHost $esxhost -Template $windowsvm -Name $vm -RunAsync -Server $vcenter
	}
	$num++
}

while(Get-Task -Server $vcenter -Status Running) { write-host "Waiting for clones to complete" ; sleep 30 }

$vmcount = Get-VM -Name 'Full*' -Server $vcenter | Measure-Object -Line
if($vmcount) {
	[string]$pass = Write-Output "PASS: Full clones created: " $vmcount.Lines
	$pass | Tee-Object -Append -FilePath $checkfile 
} else {
	[string]$err = Write-Output "FAIL: No VM created"
	$err | Tee-Object -Append -FilePath $errwarn 
	$err | Out-File -Append -FilePath $checkfile
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy Full Clones ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
