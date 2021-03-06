param(
	#[Parameter(Mandatory=$true)]
	[String]$mvip = '172.26.64.140',
	[String]$sfadmin='admin',
	[String]$sfpass='solidfire',
	[string]$linuxvm='ubuntuServer-vdb',
	[string]$windowsvm='Windows7',
	#[Parameter(Mandatory=$true)]
	[String]$vcenter = '192.168.129.228',
	[String]$vcadmin='administrator@solidfire.eng',
	[String]$vcpass='solidF!r3',
	#[Parameter(Mandatory=$true)]
	[string]$esxhost = '172.26.254.176',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$deployvol = 'deploy-dest',
	#[Parameter(Mandatory=$true)]
	[string]$svmvol = 'svm-dest',
	[Parameter(Mandatory=$true)]
	[string]$share #Low,Normal,High
)

## QOS/SIOC automation ques on the following tasks
# storage migration
# mark template as vm
# edit, create clone vm??
# delete vm
# extend datastore
# deploy vm
# vm-reconfig

	.\Initialize-SFEnvironment.ps1
	.\Initialize-PowerCLIEnvironment.ps1

Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname -note $share 

Start-Transcript -Append -Force -NoClobber -Path $transcript
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to"  $statfile

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss ")"## Start Deploy Full Clones ##" 
$header | Tee-Object -Append -FilePath $statfile

# deploy 20 ubuntu vm's.
# power on
# allow vdbench to run for 2 minutes
#power off
# purge vm
# rinse & repeat 1000 or more times
# to make life easy, match volume and datastore name

$min = 0
function checkQoS($volname) {
	$volinfo = Get-SFVolume -VolumeName $volname
	[string]$msg = (Get-Date -Format "dd-MMM-yyyy-hh:mm:ss ") + $volname + ': ' + 'Current QoS: MinQoS: ' + $volinfo.Qos.MinIOPS + ' MaxQoS: ' + $volinfo.Qos.MaxIOPS + ' BurstQoS: ' + $volinfo.Qos.BurstIOPS
	Write-Output $msg  | Tee-Object -Append -FilePath $statfile
}

#show initial QoS values
checkQoS($deployvol)

# set QoS to default 
Set-SFVolume -BurstIOPS 15000 -MaxIOPS 15000 -MinIOPS 100 -VolumeID (Get-SFVolume -VolumeName $deployvol).volumeid -Confirm:$false
Set-SFVolume -BurstIOPS 15000 -MaxIOPS 15000 -MinIOPS 100 -VolumeID (Get-SFVolume -VolumeName $svmvol).volumeid -Confirm:$false

$num = 1
$cycle = 1
1..10 | foreach {
	checkQoS($deployvol)
	# set VM disk shares at High/Normal/Low
	get-vm -Name $linuxvm|Get-VMResourceConfiguration|Set-VMResourceConfiguration -Disk (Get-HardDisk -VM $linuxvm) -DiskSharesLevel $share
	
	$msg = (Get-Date -Format "`n`n dd-MMM-yyyy-hh:mm:ss ") + "*** Begin Deploy Cycle " + $cycle + " ***`n"
	Write-Output $msg | Tee-Object -Append -FilePath $statfile
	
	# deploy and power on 20 vms
	1..20 | foreach {
		[string]$vm = 'Unmap' + $num
		
		[string]$msg = (Get-Date -Format "dd-MMM-yyyy-hh:mm:ss ") + "Deploying: " + $vm
		Write-Output $msg | Tee-Object -Append -FilePath $statfile
		$newvm = New-VM -Datastore $deployvol -VMHost $esxhost -vm $linuxvm -Name $vm
		sleep 3
		$msg = (Get-Date -Format "dd-MMM-yyyy-hh:mm:ss ")+ "Power on: " + $newvm.Name
		Write-Output $msg | Tee-Object -Append -FilePath $statfile
		Start-VM -Confirm:$false -VM $newvm.Name
		checkQoS($deployvol)
		$num++
	}
	
	$msg = (Get-Date -Format "dd-MMM-yyyy-hh:mm:ss ") + "Allow vdbench to run for 2 minutes" 
	Write-Output $msg | Tee-Object -Append -FilePath $statfile
	sleep 120
	checkQoS($deployvol)
	
	$msg = (Get-Date -Format "dd-MMM-yyyy-hh:mm:ss ") + "Power Off VM's "
	Write-Output $msg | Tee-Object -Append -FilePath $statfile
	$vms = Get-VM -Name 'Unmap*'
	foreach ($vm in $vms) {
		Stop-VM -Confirm:$false -VM $vm
	}
	# wait for power off's to complete
	sleep 10
	checkQoS($deployvol)
	
	# move vms to a new datstore
	foreach ( $vm in (Get-VM -Name 'Unmap*')) {
		$msg = "Storage Migrating: " + $vm
		Write-Output $msg | Tee-Object -Append -FilePath $statfile
		Move-VM -Datastore $svmvol -Confirm:$false -VM $vm 
		checkQoS($deployvol)
		checkQoS($svmvol)
	}
	
	# power vms back on
	foreach ( $vm in (Get-VM -Name 'Unmap*')) {
		$msg = "PowerOn: " + $vm
		Write-Output $msg | Tee-Object -Append -FilePath $statfile
		Start-VM -Confirm:$false -VM $vm
		checkQos($svmvol)
	}
	
	$msg = (Get-Date -Format "dd-MMM-yyyy-hh:mm:ss ") + "Allow vdbench to run for 2 minutes" 
	Write-Output $msg | Tee-Object -Append -FilePath $statfile
	sleep 120
	checkQoS($svmvol)
	
	# power vms back off
	foreach ( $vm in (Get-VM -Name 'Unmap*')) {
		$msg = "PowerOff: " + $vm
		Write-Output $msg | Tee-Object -Append -FilePath $statfile
		Stop-VM -Confirm:$false -VM $vm
	}
	checkQoS($svmvol)
	
	# purge vms
	foreach ($vm in (Get-VM -Name 'Unmap*' )) {
		$msg = "Purge: " + $vm
		Write-Output $msg | Tee-Object -Append -FilePath $statfile
		Remove-VM -vm $vm -Confirm:$false -DeletePermanently -RunAsync
	}
	checkQoS($svmvol)
	$cycle++
}

# set shares to Normal for a clean up
Write-Output "CleanUp: Return VM disk shares to Normal" | Tee-Object -Append -FilePath $statfile
get-vm -Name  $linuxvm|Get-VMResourceConfiguration|Set-VMResourceConfiguration -Disk (Get-HardDisk -VM  $linuxvm) -DiskSharesLevel Normal

Write-Output "CleanUp: Return QoS to Default" | Tee-Object -Append -FilePath $statfile

# set QoS to default for clean up
Set-SFVolume -BurstIOPS 15000 -MaxIOPS 15000 -MinIOPS 100 -VolumeID (Get-SFVolume -VolumeName $deployvol).volumeid -Confirm:$false
Set-SFVolume -BurstIOPS 15000 -MaxIOPS 15000 -MinIOPS 100 -VolumeID (Get-SFVolume -VolumeName $svmvol).volumeid -Confirm:$false

Disconnect-SFCluster 
Disconnect-VIServer -Confirm:$false

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss ")"## End Deploy Full Clones ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
