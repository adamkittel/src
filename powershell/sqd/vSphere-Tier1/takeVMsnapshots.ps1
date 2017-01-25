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
	[string]$powerstate 
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript


[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

# get list of vm's 
$vms = Get-VM 
$snapname = Get-Date -Format "dd-MMM-yyyy-HH.mm.ss"

foreach ($vm in $vms) {
	if($vm.PowerState -like $powerstate) {
		$newsnap = New-Snapshot -Confirm:$false -Description "test snapshot" -Memory:$true -Name $snapname -RunAsync  -VM $vm
		if ($newsnap) {
			[string]$pass = Write-Output "PASS: Snapshot VM: " $vm $newsnap.name
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Snapshot not taken: " $vm
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
}
	
[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Take vm Snapshots ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
