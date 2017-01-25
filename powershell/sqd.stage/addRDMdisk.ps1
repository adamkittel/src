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
	[string]$persistence #Persistent, NonPersistent, IndependentPersistent, IndependentNonPersistent
)
# disktype = RawVirtual RawPhysical 
# persistence =  Persistent, NonPersistent, IndependentPersistent, IndependentNonPersistent, and Undoable

. z:\home\src\powershell\sqd\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("addRDMdisk.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Add RDM to VM ##" 
$header | Tee-Object -Append -FilePath $checkfile

# get list of full cloned vm's
$vms = Get-VM -Name '*Full*' -Server $vcenter
# get list of rdm volumes
$rdmvols = Get-SFVolume -VolumeName '*vmw-rdm*'

#make sure all vm's are powered off
Get-VM -Server $vcenter | Stop-VM -Confirm:$false -Server $vcenter -ErrorAction SilentlyContinue

# add rdm and regular flat disk to each Full clone
$disktype = 'rawVirtual'
$persistence = 'IndependentNonPersistent'
$num = 1
foreach ($vm in $vms) {
	$dev = '/vmfs/devices/disks/naa.' + $rdmvols[$num].Scsi_NAA_DeviceID
	$addrdm1 = New-HardDisk -VM $vm -DiskType $disktype -DeviceName $dev -Persistence $persistence -Server $vcenter
	if ($addrdm1) {
		[string]$pass = Write-Output "PASS: RDM added: " $vm $addrdm1.CapacityGB $addrdm1.Filename
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		[string]$err = Write-Output "FAIL: RDM NOT added: " $vm
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
	$addrdm2 = New-HardDisk -VM $vm -DiskType Flat -CapacityGB 200 -StorageFormat EagerZeroedThick -Datastore  -Server $vcenter
	if ($addrdm2) {
		[string]$pass = Write-Output "PASS: RDM added: " $vm $addrdm2.CapacityGB $addrdm2.Filename
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		[string]$err = Write-Output "FAIL: RDM NOT added: " $vm
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
	$num++
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Add RDM to VM ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
