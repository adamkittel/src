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

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript


[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start SFcluster setup ##" 
$header | Tee-Object -Append -FilePath $statfile

# create account 
Write-Output "*Create account " | Tee-Object -Append -FilePath $statfile
$account = $clustername + 'account'
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

$vmwVAG = $clustername + 'VAG'
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

# setup min QoS value volumes
Write-Output "*Create min QoS value volumes " | Tee-Object -Append -FilePath $statfile
$num=1
1..20 | foreach {
	[string]$vol = $clustername + $minprefix + $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) 
	{ 
		[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol | Tee-Object -Append -FilePath $statfile
		$pass | Tee-Object -Append -FilePath $statfile
	} else { 
		$minvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 100 -Enable512e $true -MaxIOPS 100 -MinIOPS 100 -Name $vol -TotalSize 250000000000 
		if($minvol.VolumeID) { 
			Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $minvol.VolumeID
			[string]$pass = Write-Output "PASS: created volume & added to VAG: " $minvol.VolumeID $vol $vag.VolumeAccessGroupID
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$num++
}

# setup max QoS value volumes
Write-Output "*Create max QoS value volumes " 
$num=1
1..20 | foreach {
	[string]$vol = $clustername + $maxprefix + $num
	if(Get-SFVolume -VolumeName $vol  -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol | Tee-Object -Append -FilePath $statfile
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		$maxvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 100000 -Enable512e $true -MaxIOPS 100000 -MinIOPS 15000 -Name $vol -TotalSize 250000000000 -Verbose 
		if($maxvol.VolumeID) { 
			Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $maxvol.VolumeID
			[string]$pass = Write-Output "PASS: created volume & added to VAG: " $maxvol.VolumeID $vol $vag.VolumeAccessGroupID
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}	
	}
	$num++
}

# setup default QoS value volumes
Write-Output "*Create default QoS value volumes " | Tee-Object -Append -FilePath $statfile
$num=1
1..20 | foreach {
	[string]$vol = $clustername + $defprefix + $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol 
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		$defvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -TotalSize 250000000000 -Verbose
		if($defvol.VolumeID) { 
			Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $defvol.VolumeID
			[string]$pass = Write-Output "PASS: created volume & added to VAG: " $defvol.VolumeID $vol $vag.VolumeAccessGroupID
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$num++
}

# setup rdm volumes
Write-Output "*Create rdm volumes with default QoS values " | Tee-Object -Append -FilePath $statfile
$num=1
1..20 | foreach {
	[string]$vol = $clustername + $rdmprefix + $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol 
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		$rdmvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -TotalSize 250000000000 -Verbose		
		if($rdmvol.VolumeID) { 
			Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $rdmvol.VolumeID
			[string]$pass = Write-Output "PASS: created volume & added to VAG: " $rdmvol.VolumeID $vol $vag.VolumeAccessGroupID
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$num++
}

# setup template volumes
Write-Output "*Create template volumes with default QoS values " | Tee-Object -Append -FilePath $statfile
$num=1
1..20 | foreach {
	[string]$vol = $clustername + $tmplprefix + $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol 
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		$tmplvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -TotalSize 250000000000 -Verbose		
		if($tmplvol.VolumeID) { 
			Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $tmplvol.VolumeID
			[string]$pass = Write-Output "PASS: created volume & added to VAG: " $tmplvol.VolumeID $vol $vag.VolumeAccessGroupID
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$num++
}

# setup flat additional disk volumes
Write-Output "*Create flat vmdk volumes with default QoS values " | Tee-Object -Append -FilePath $statfile
$num=1
1..20 | foreach {
	[string]$vol = $clustername + $flatprefix + $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol 
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		$flatvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -TotalSize 250000000000 -Verbose		
		if($rdmvol.VolumeID) { 
			Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $flatvol.VolumeID
			[string]$pass = Write-Output "PASS: created volume & added to VAG: " $flatvol.VolumeID $vol $vag.VolumeAccessGroupID
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$num++
}

# setup remaining volumes to test LUN maximum
Write-Output "*Create remaining volumes to test LUN maximum default QoS values " | Tee-Object -Append -FilePath $statfile
$num=1
1..135 | foreach {
	[string]$vol = $clustername + 'vmw-rem'+ $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $remvol.VolumeID $vol 
		$pass | Tee-Object -Append -FilePath $statfile
	} else {
		$remvol = New-SFVolume -AccountID $sfvmw.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -TotalSize 250000000000 -Verbose
		if($remvol.VolumeID) { 
			Set-SFVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeIDs $remvol.VolumeID
			[string]$pass = Write-Output "PASS: created volume & added to VAG: " $remvol.VolumeID $vol $vag.VolumeAccessGroupID
			$pass | Tee-Object -Append -FilePath $statfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume create failed for " $vol
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$num++
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End SFcluster setup ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
