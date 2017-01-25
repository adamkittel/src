param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$powerstate  #PoweredOn PoweredOff
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("takeVMsnapshot.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Take vm Snapshots ##" 
$header | Tee-Object -Append -FilePath $checkfile


# get list of vm's 
$vms = Get-VM -Server $vcenter
$snapname = Get-Date -Format "dd-MMM-yyyy-HH.mm.ss"

foreach ($vm in $vms) {
	if($vm.PowerState -like $powerstate) {
		$newsnap = New-Snapshot -Confirm:$false -Description "test snapshot" -Memory:$true -Name $snapname -RunAsync -Server $vcenter -VM $vm
		if ($newsnap) {
			[string]$pass = Write-Output "PASS: Snapshot VM: " $vm $newsnap.name
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Snapshot not taken: " $vm
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
}
	
[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Take vm Snapshots ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
