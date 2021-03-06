param(
	#[Parameter(Mandatory=$true)]
	[String]$mvip = '192.168.139.165',
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='32bitlinux',
	[string]$windowsvm='Windows7',
    #[Parameter(Mandatory=$true)]
	[string]$vmprefix='QE',
	#[Parameter(Mandatory=$true)]
	[String]$vcenter = '172.24.89.120',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$esxhost = '172.24.67.2',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
    #[Parameter(Mandatory=$true)]
    [string]$note = 'vcp',
    #[Parameter(Mandatory=$true)]
    [string]$source = 'siocsrc',
    [string]$dest1 = 'sioc1tb',
    [string]$dest2 = 'sioc2tb',
    [string]$dest3 = 'sioc3tb',
    [string]$dest4 = 'sioc5tb',
    #[Parameter(Mandatory=$true)]
    [string]$share = 'High',
    [Parameter(Mandatory=$true)]
    [int]$count
)

# init powercli and SF powershell environments
.\Initialize-SFEnvironment.ps1
.\Initialize-PowerCLIEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -Password $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# set scriptname and run include
[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -scriptname $scriptname -note $note
Start-Transcript -Append -Force -NoClobber -Path $transcript

# start transcript and mark script start
[string]$header = '## ' + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + ' Start ' + $scriptname + ' ##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

# setup functions
#wait for tasks to complete
# CloneVM_Task RelocateVM_Task ReconfigVM_Task Destroy_Task 
function taskwait([string]$taskname) {
    while((Get-Task -Status Running) -like $taskname) {
	sleep 3
	Write-Output "Waiting for tasks to complete" | Tee-Object -Append -FilePath $statfile
	}
}

# migrate vms to alternate Datastore (VmMigratedEvent)
function migrate($vmlist,$dstore) {
     foreach ($vm in $vmlist) {
         Write-Output ("Migrate: " + $vm + " To " + $dstore) | Tee-Object -Append -FilePath $statfile
         Move-VM -Datastore $dstore -Confirm:$false -VM $vm ##-RunAsync
		 sleep 30
     } Clear-Variable -Name vm -Force -Confirm:$false
 }
  
# add hard disk to vms (VmReconfiguredEvent)
 function addhd($vmlist,$dstore) {
     foreach($vm in $vmlist) {
         Write-Output ("Adding hard disk to " + $vm) | Tee-Object -Append -FilePath $statfile
         New-HardDisk -CapacityGB 50 -Confirm:$false -Datastore $dstore -DiskType Flat -StorageFormat EagerZeroedThick -VM $vm
         get-vm -Name $vm|Get-VMResourceConfiguration|Set-VMResourceConfiguration -Disk (Get-HardDisk -VM $linuxvm) -DiskSharesLevel $share
     } Clear-Variable -Name vm -Force -Confirm:$false
 
}
  
# clone vms (VmDeployedEvent)
 function clonevm($vmlist,$dstore) {
     foreach($vm in $vmlist) {
         Write-Output ("Cloning " + $vm) | Tee-Object -Append -FilePath $statfile
         New-VM -Confirm:$false -Name ($vm + "-clone") -Datastore $dstore -VMHost $esxhost -vm $vm -RunAsync
     } Clear-Variable -Name vm -Force -Confirm:$false
 }
 
 
# delete vms from disk (VmRemovedEvent)
 function destroyvm($vmlist) {
     foreach($vm in $vmlist) {
         Write-Output ("Destroying " + $vm) | Tee-Object -Append -FilePath $statfile
         Remove-VM -VM $vm -Confirm:$false -DeletePermanently ##-RunAsync
		 sleep 30
     } Clear-Variable -Name vm -Force -Confirm:$false
 }
 
#set vm shares (VmReconfiguredEvent)
function vmshares($vmlist,$share) {
	foreach($vm in $vmlist) {
	Write-Output ("Setting vm shares: " + $vm + " Set to " + $share) | Tee-Object -Append -FilePath $statfile
	get-vm -Name $linuxvm|Get-VMResourceConfiguration|Set-VMResourceConfiguration -Disk (Get-HardDisk -VM $linuxvm) -DiskSharesLevel $share
	}
}

function step($stepname) {
    $dest1id = (Get-SFVolume -Name $dest1).VolumeID
    $dest2id = (Get-SFVolume -Name $dest2).VolumeID
    $dest3id = (Get-SFVolume -Name $dest3).VolumeID
    $dest4id = (Get-SFVolume -Name $dest4).VolumeID
    $dest1inf = Get-SFVolume -VolumeID $dest1id
    $dest2inf = Get-SFVolume -VolumeID $dest2id
    $dest3inf = Get-SFVolume -VolumeID $dest3id
    $dest4inf = Get-SFVolume -VolumeID $dest4id
    $msg1 = ($stepname + ": QoS:" + " Vol " + $dest1 + ": Min " + $dest1inf.QoS.Miniops + ": Max " + $dest1inf.QoS.MaxIOPS + ": Burst " + $dest1inf.QoS.BurstIOPS) 
    $msg2 = ($stepname + ": QoS:" + " Vol " + $dest2 + ": Min " + $dest2inf.QoS.Miniops + ": Max " + $dest2inf.QoS.MaxIOPS + ": Burst " + $dest2inf.QoS.BurstIOPS) 
    $msg3 = ($stepname + ": QoS:" + " Vol " + $dest3 + ": Min " + $dest3inf.QoS.Miniops + ": Max " + $dest3inf.QoS.MaxIOPS + ": Burst " + $dest3inf.QoS.BurstIOPS) 
    $msg4 = ($stepname + ": QoS:" + " Vol " + $dest4 + ": Min " + $dest4inf.QoS.Miniops + ": Max " + $dest4inf.QoS.MaxIOPS + ": Burst " + $dest4inf.QoS.BurstIOPS) 
    $msg1 | Tee-Object -Append -FilePath $statfile
    $msg2 | Tee-Object -Append -FilePath $statfile
    $msg3 | Tee-Object -Append -FilePath $statfile
    $msg4 | Tee-Object -Append -FilePath $statfile
}

# import initial ubuntu template
[string]$hostip = $esxhost.split('.')[3]
Import-VApp -Source "e:\solidfire\ova\ubuntuServer-vdb.ova" -VMHost $esxhost -Name $linuxvm -Datastore $source
taskwait "Deploy OVF template"

# set vm resource shares
vmshares $linuxvm "High"

# deploy, migrate, reconfig, clone, destroy
$num = 1
1..$count | foreach {
    [string]$vmname = $prefix + 'VM' + $num
    Write-Output ("Deploying: " + $vmname) | Tee-Object -Append -FilePath $statfile
    New-VM -Datastore $dest1 -VMHost $esxhost -vm $linuxvm -Name $vmname -Confirm:$false -RunAsync
    $num++
}

# wait for tasks to finish
taskwait "CloneVM_Task"

# get a list of tenant vm's
$dest1vms = (Get-VM -Datastore $dest1).Name

# move vms to a new datstore
step "Migrate"
migrate $dest1vms $dest2
    
# wait for tasks to finish
taskwait "RelocateVM_Task"
	
# add a disk to the vm's
$dest2vms = (Get-VM -Datastore $dest2).Name
step "Add HD"
addhd $dest2vms $dest2
	
# wait for tasks to finish
taskwait "ReconfigVM_Task"
	
# clone to $dest then destroy original
step "Clone"
clonevm $dest2vms $dest3

# wait for tasks to finish
taskwait "CloneVM_Task"
$dest3vms = (Get-VM -Datastore $dest3).Name

# destroy $dest2 vms
step "Destroy"
destroyvm $dest2vms

# add a disk to the vm's
step "Add HD"
addhd $dest3vms $dest3

# wait for tasks to finish
taskwait "ReconfigVM_Task"

# change DiskSharesLevel to normal
step "Set Shares"
vmshares $dest3vms "Normal"

# wait for tasks to finish
taskwait "ReconfigVM_Task"

# clone $dest3 vm's to $dest4
step "Clone"
clonevm $dest3vms $dest4

# wait for tasks to finish
taskwait "CloneVM_Task"

# change DiskSharesLevel to High
step "Set Shares"
vmshares $dest3vms "High"

# wait for tasks to finish
taskwait "ReconfigVM_Task"

# migrate $dest3 vms to $dest4
step "Migrate"
migrate $dest3vms $dest4

# wait for tasks to finish
taskwait "RelocateVM_Task"

$dest4vms = (Get-VM -Datastore $dest4).Name

# change DiskSharesLevel to normal
#vmshares $dest4vms "High"

# clone $dest4 vm's to $dest4
step "Clone"
clonevm $dest4vms $dest4

# wait for tasks to finish
taskwait "CloneVM_Task"

# add a disk to the vm's
step "Add HD"
addhd $dest4vms $dest4

# wait for tasks to finish
taskwait "ReconfigVM_Task"

# purge all vms
step "Destroy"
destroyvm $dest4vms


Write-Host -BackgroundColor Black -ForegroundColor Cyan "End logging to" `n $statfile `n $errwarn 
[string]$footer = "`n`n## " + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + " End " + $scriptname + " ##"
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
Disconnect-SFCluster
Disconnect-VIServer -Confirm:$false
