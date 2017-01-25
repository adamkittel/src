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
	[string]$psp
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("changePSP.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Change Path selection policy ##" 
$header | Tee-Object -Append -FilePath $checkfile

[string]$msg = Write-Output "*Change path selection policy to" $psp
$msg | Tee-Object -Append -FilePath $checkfile	

# get all SF volumes not using $psp
$sfvols = Get-ScsiLun -CanonicalName '*6f47*' -VmHost $esxhost -Server $vcenter
$num = 1
foreach ($sfvol in $sfvols) {
	if ($sfvol.MultipathPolicy -ne $psp) {
		$newpsp = Set-ScsiLun -MultipathPolicy $psp -Confirm:$false -ScsiLun $sfvol
		[string]$msg = Write-Output $num $newpsp.CanonicalName $newpsp.MultipathPolicy
		$msg | Tee-Object -Append -FilePath $checkfile	
	}
	$num++
}
		
[string]$msg = Write-Output "*Rescan adapters"
$pass | Tee-Object -Append -FilePath $checkfile	
Get-VMHostStorage -RescanAllHba -VMHost $esxhost

#recheck volume connectivity
$sfvols = Get-ScsiLun -CanonicalName '*6f47*' -VmHost $esxhost -Server $vcenter

foreach ($sfvol in $sfvols) {
	if ($sfvol.MultipathPolicy -eq $psp) {
		[string]$pass = Write-Output "PASS: PSP changed: " $sfvol.CanonicalName $sfvol.MultipathPolicy
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		[string]$err = Write-Output "FAIL: PSP NOT changed: " $sfvol.CanonicalName $sfvol.MultipathPolicy
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
}




[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Change path selection policy ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
