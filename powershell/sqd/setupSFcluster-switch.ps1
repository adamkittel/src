param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$maxprefix='vmw-max',
	[string]$minprefix='vmw-min',
	[string]$defprefix='vmw-def',
	[string]$rdmprefix='vmw-rdm',
	[string]$tmplprefix='vmw-tmpl',
	[string]$flatprefix='vmw-flat',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

# source include file
#. C:\RQD\scripts\include.ps1
$clustername = (Get-SFClusterInfo).name.split('-')[0]
$hostprefix = $esxhost.split('.')[3]
$path = 'c:\RQD\logs\' + $hostprefix + $clustername + '\'

function logSetup ([string]$basename){
	[string]$rundate = Get-Date -Format "dd-MMM-yyyy-hhmmss"
	[string]$logpath = $path + '\' + $rundate
	if(!(Test-Path -Path $logpath)) {
		New-Item -ItemType directory -Path $logpath
	}
	
	[string]$statfile = "$logpath\$basename.stat.log"
	[string]$checkfile = "$logpath\$basename.checklist.log"
	[string]$errwarn = "$logpath\$basename.errwarn.log"
	[string]$stdErrLog = "$logpath\$basename.errwarn.log"
		
	return $statfile,$checkfile,$errwarn,$logpath
}


# init powercli and SF powershell environments
#c:\RQD\scripts\Initialize-SFEnvironment.ps1
#c:\RQD\scripts\Initialize-PowerCLIEnvironment.ps1
z:\home\src\powershell\sqd\Initialize-PowerCLIEnvironment.ps1
z:\home\src\powershell\sqd\Initialize-SFEnvironment.ps1

logSetup("setupSFcluster.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

$clustername = ((Get-SFClusterInfo).name.split('-')[0])
$hostprefix = $esxhost.split('.')[3]

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start SFcluster setup ##" 
$header | Tee-Object -Append -FilePath $checkfile

# create account 
Write-Output "*Create account " | Tee-Object -Append -FilePath $checkfile
$account = $hostprefix + $clustername + 'account'
if(Get-SFAccount -UserName $account -ErrorAction SilentlyContinue) { 
	[string]$exists = Write-Output "PASS: account Already exists" $clustername
	$exists | Tee-Object -Append -FilePath $checkfile
	$sfvmw = Get-SFAccount -UserName $account
	} else {	
	Write-Output "*Add account " | Tee-Object -Append -FilePath $checkfile
	New-SFAccount -InitiatorSecret solidfire1234 -TargetSecret 1234solidfire -UserName $account
	if ($sfvmw = Get-SFAccount -UserName $account -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: AccountID: " $sfvmw.AccountID
		$pass | Tee-Object -Append -FilePath $checkfile
	}
}

$vmwVAG = $hostprefix + $clustername + 'VAG'
$vag = Get-SFVolumeAccessGroup -VolumeAccessGroupName $vmwVAG -ErrorAction SilentlyContinue
if ($vag.VolumeAccessGroupID) {
	[string]$pass = Write-Output "PASS: Volume Access Group already exists:" $vag.VolumeAccessGroupID ": Initiators " $vag.Initiators
	$pass | Tee-Object -Append -FilePath $checkfile 
} else {
	$vag = New-SFVolumeAccessGroup -Name $vmwVAG 
	if ($vag.VolumeAccessGroupID) {
		[string]$pass = Write-Output "PASS: Created Volume Access Group:" $vag.VolumeAccessGroupID 
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		[string]$err = Write-Output "FAIL: Did not create volume access group"
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
}

function makevols ([string]$prefix,[string]$burstiops,[string]$maxiops,[string]$miniops) {
	$num=1
	1..20 | foreach {
		[string]$vol = $hostprefix + $prefix + $num
		if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) 
		{ 
			[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol | Tee-Object -Append -FilePath $checkfile
			$pass | Tee-Object -Append -FilePath $checkfile
		} else { 
			$newvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS $burstiops -Enable512e $true -MaxIOPS $maxiops -MinIOPS $miniops -Name $vol -TotalSize 250000000000
			if($newvol.VolumeID) { 
				[string]$pass = Write-Output "PASS: created volume: " $vol $newvol.VolumeID
				$pass | Tee-Object -Append -FilePath $checkfile 
			} else {
				[string]$err = Write-Output "FAIL: Volume create failed for " $vol
				$err | Tee-Object -Append -FilePath $errwarn 
				$err | Out-File -Append -FilePath $checkfile
			}
		}
		$num++
	}
}

# volume types and default QoS settings
$voltypes = 'min','max','def','rdm','tmpl','flat','rem'
[string]$burstiops = '15000'
[string]$maxiops = '15000'
[string]$miniops = '100'

foreach ($voltype in $voltypes) {
	switch ($voltype) {
		"min" {
			[string]$prefix = 'vmw-minQOS'
			[string]$burstiops = '100'
			[string]$maxiops = '100'
			[string]$miniops = '100'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"max" {
			[string]$prefix = 'vmw-maxQOS'
			[string]$burstiops = '100000'
			[string]$maxiops = '100000'
			[string]$miniops = '15000'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"def" {
			[string]$prefix = 'vmw-defaultQOS'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"rdm" {
			[string]$prefix = 'vmw-rdm'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"tmpl" {
			[string]$prefix = 'vmw-template'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"flat" {
			[string]$prefix = 'vmw-flat'
			makevols $prefix $burstiops $maxiops $miniops
			}
	}			
}

# setup remaining volumes to test LUN maximum
Write-Output "*Create remaining volumes to test LUN maximum default QoS values " | Tee-Object -Append -FilePath $checkfile
$num=1
1..135 | foreach {
	[string]$vol = $hostprefix + 'vmw-rem'+ $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $remvol.VolumeID $vol 
		$pass | Tee-Object -Append -FilePath $checkfile
	} else {
		$newvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -TotalSize 250000000000 -Verbose
		if($newvol.VolumeID) { 
			[string]$pass = Write-Output "PASS: created volume: " $vol $remvol.VolumeID 
			$pass | Tee-Object -Append -FilePath $checkfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
	$num++
}

# add volumes to VAG
[string]$infomsg = Write-Output "Add volumes to VAG: " $vag.Name $vag.VolumeAccessGroupID
$infomsg | Tee-Object -Append -FilePath $checkfile 
$volids = (Get-SFVolumeForAccount -AccountID $sfvmw.AccountID).VolumeID
Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $volids

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End SFcluster setup ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript
