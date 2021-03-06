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
	[Parameter(Mandatory=$true)]
	[String]$vcadmin,
	[Parameter(Mandatory=$true)]
	[String]$vcpass,
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript


[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

# create account 
[string]$hostip = $esxhost.split('.')[3]
Write-Output "*Create account " | Tee-Object -Append -FilePath $statfile
$account = $hostip + 'account'
if(Get-SFAccount -UserName $account -ErrorAction SilentlyContinue) { 
	[string]$exists = Write-Output "PASS: account Already exists" $clustername
	$exists | Tee-Object -Append -FilePath $statfile
	$sfvmw = Get-SFAccount -UserName $account
	} else {	
	Write-Output "*Add account " | Tee-Object -Append -FilePath $statfile
	New-SFAccount -InitiatorSecret solidfire1234 -TargetSecret 1234solidfire -UserName $account
	if ($sfvmw = Get-SFAccount -UserName $account -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: AccountID: " $sfvmw.AccountID
		$pass | Tee-Object -Append -FilePath $statfile
	}
}

# create VAG
$vmwVAG = $hostip + 'VAG'
$vag = Get-SFVolumeAccessGroup -VolumeAccessGroupName $vmwVAG -ErrorAction SilentlyContinue
if ($vag.VolumeAccessGroupID) {
	[string]$pass = Write-Output "PASS: Volume Access Group already exists:" $vag.VolumeAccessGroupID ": Initiators " $vag.Initiators
	$pass | Tee-Object -Append -FilePath $statfile 
} else {
	$vag = New-SFVolumeAccessGroup -Name $vmwVAG 
	if ($vag.VolumeAccessGroupID) {
		[string]$pass = Write-Output "PASS: Created Volume Access Group:" $vag.VolumeAccessGroupID 
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		[string]$err = Write-Output "FAIL: Did not create volume access group"
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
}

function makevols ([string]$prefix,[string]$burstiops,[string]$maxiops,[string]$miniops) {
	$num=1
	1..20 | foreach {
		[string]$vol = $hostip + $prefix + $num
		if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) 
		{ 
			[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol | Tee-Object -Append -FilePath $statfile
			$pass | Tee-Object -Append -FilePath $statfile
		} else { 
			$newvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS $burstiops -Enable512e $true -MaxIOPS $maxiops -MinIOPS $miniops -Name $vol -GB 250
			if($newvol.VolumeID) { 
				[string]$pass = Write-Output "PASS: created volume: " $vol $newvol.VolumeID
				$pass | Tee-Object -Append -FilePath $statfile 
			} else {
				[string]$err = Write-Output "FAIL: Volume create failed for " $vol
				$err | Tee-Object -Append -FilePath $errwarn 
				$err | Out-File -Append -FilePath $statfile
			}
		}
		$num++
	}
}

# volume types and default QoS settings
## don't make 3 QoS groups. use SF powershell tools to set QoS on demand
$voltypes = 'min','max','def','rdm','tmpl','flat','rem'
##$voltypes = 'def','rdm','tmpl','flat','rem'
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
			[string]$burstiops = '15000'
			[string]$maxiops = '15000'
			[string]$miniops = '100'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"rdm" {
			[string]$prefix = 'vmw-rdm'
			[string]$burstiops = '15000'
			[string]$maxiops = '15000'
			[string]$miniops = '100'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"tmpl" {
			[string]$prefix = 'vmw-template'
			[string]$burstiops = '15000'
			[string]$maxiops = '15000'
			[string]$miniops = '100'
			makevols $prefix $burstiops $maxiops $miniops
			}
		"flat" {
			[string]$prefix = 'vmw-flat'
			[string]$burstiops = '15000'
			[string]$maxiops = '15000'
			[string]$miniops = '100'
			makevols $prefix $burstiops $maxiops $miniops
			}
	}			
}

# setup remaining volumes to test LUN maximum
Write-Output "*Create remaining volumes to test ESXi LUN maximum " | Tee-Object -Append -FilePath $statfile
$num=1
1..235 | foreach {
	[string]$vol = $hostip + 'vmw-rem'+ $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $remvol.VolumeID $vol 
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		$newvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -GB 2 -Verbose
		if($newvol.VolumeID) { 
			[string]$pass = Write-Output "PASS: created volume: " $vol $remvol.VolumeID 
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$num++
}

# add volumes to VAG
[string]$infomsg = Write-Output "Add volumes to VAG: " $vag.Name $vag.VolumeAccessGroupID
$infomsg | Tee-Object -Append -FilePath $statfile 
$volids = (Get-SFVolumeForAccount -AccountID $sfvmw.AccountID).VolumeID
Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeID $volids

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End SFcluster setup ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
