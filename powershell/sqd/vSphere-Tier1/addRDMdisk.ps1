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
	[string]$persistence 
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

# get list of full cloned vm's
$vms = Get-VM -Name '*Full*' 
# get list of rdm volumes
$rdmvols = Get-SFVolume -VolumeName '*vmw-rdm*'

#make sure all vm's are powered off
Get-VM  | Stop-VM -Confirm:$false  -ErrorAction SilentlyContinue

# add rdm and regular flat disk to each Full clone
$disktype = 'rawVirtual'
$persistence = 'IndependentNonPersistent'
$num = 1
foreach ($vm in $vms) {
	$dev = '/vmfs/devices/disks/naa.' + $rdmvols[$num].Scsi_NAA_DeviceID
	$addrdm1 = New-HardDisk -VM $vm -DiskType $disktype -DeviceName $dev -Persistence $persistence 
	if ($addrdm1) {
		[string]$pass = Write-Output "PASS: RDM added: " $vm $addrdm1.CapacityGB $addrdm1.Filename
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		[string]$err = Write-Output "FAIL: RDM NOT added: " $vm
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
	$addrdm2 = New-HardDisk -VM $vm -DiskType Flat -CapacityGB 200 -StorageFormat EagerZeroedThick -Datastore  
	if ($addrdm2) {
		[string]$pass = Write-Output "PASS: RDM added: " $vm $addrdm2.CapacityGB $addrdm2.Filename
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		[string]$err = Write-Output "FAIL: RDM NOT added: " $vm
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
	$num++
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Add RDM to VM ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
