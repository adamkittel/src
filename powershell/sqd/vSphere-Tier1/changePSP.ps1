param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$psp
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

[string]$msg = Write-Output "*Change path selection policy to" $psp
$msg | Tee-Object -Append -FilePath $statfile	

# get all SF volumes not using $psp
$sfvols = Get-ScsiLun -CanonicalName '*6f47*' -VmHost $esxhost 
$num = 1
foreach ($sfvol in $sfvols) {
	if ($sfvol.MultipathPolicy -ne $psp) {
		$newpsp = Set-ScsiLun -MultipathPolicy $psp -Confirm:$false -ScsiLun $sfvol
		[string]$msg = Write-Output $num $newpsp.CanonicalName $newpsp.MultipathPolicy
		$msg | Tee-Object -Append -FilePath $statfile	
	}
	$num++
}
		
[string]$msg = Write-Output "*Rescan adapters"
$pass | Tee-Object -Append -FilePath $statfile	
Get-VMHostStorage -RescanAllHba -VMHost $esxhost

#recheck volume connectivity
$sfvols = Get-ScsiLun -CanonicalName '*6f47*' -VmHost $esxhost 

foreach ($sfvol in $sfvols) {
	if ($sfvol.MultipathPolicy -eq $psp) {
		[string]$pass = Write-Output "PASS: PSP changed: " $sfvol.CanonicalName $sfvol.MultipathPolicy
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		[string]$err = Write-Output "FAIL: PSP NOT changed: " $sfvol.CanonicalName $sfvol.MultipathPolicy
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
}




[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Change path selection policy ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
