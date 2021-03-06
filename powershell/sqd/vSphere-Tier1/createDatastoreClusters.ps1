param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='solidfire',
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

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

[string]$msg = Write-Output "*Rescan adapters"
$msg | Tee-Object -Append -FilePath $statfile
Get-VMHostStorage -vmHost $esxhost -RescanAllHba 

[string]$hostip = $esxhost.split('.')[3]
[string]$account = $hostip + 'account'
[string]$accountid = (Get-SFAccountByName -UserName $account).AccountID

Write-Output "*Create default QoS value datastores with SIOC enabled" | Tee-Object -Append -FilePath $statfile
#$vols = Get-SFVolume -VolumeName "*default*"
$volnum = 1
$vols = (Get-SFVolumeForAccount -Accountid $accountid).VolumeName | where { $_ -like '*vmw-defaultQOS*' }
[string]$defprefix = $hostip + 'defaultQoS-'

foreach ($vol in $vols) {
	[string]$ds = $defprefix + $volnum
	$volpath = 'naa.' + ((Get-SFVolume -VolumeName $vol).Scsi_NAA_DeviceID)
	if(Get-Datastore -Name $ds -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds  
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$volnum++
}

# do not create 3 QoS groups. instead, use SF powershell tools to set QoS on demand
Write-Output "*Create minimum QoS value datastores " | Tee-Object -Append -FilePath $statfile
$volnum = 1
$vols = (Get-SFVolumeForAccount -Accountid $accountid).VolumeName | where { $_ -like '*min*' }
[string]$minprefix = $hostip + 'minQoS-'
[string]$msg = Write-Output "*Create datastores with SIOC enabled"
$msg | Tee-Object -Append -FilePath $statfile

foreach ($vol in $vols) {
	[string]$ds = $minprefix + $volnum
	$volpath = 'naa.' + ((Get-SFVolume -VolumeName $vol).Scsi_NAA_DeviceID)
	if(Get-Datastore -Name $ds   -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost  
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds  
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$volnum++
}

Write-Output "*Create maximum QoS value datastores " | Tee-Object -Append -FilePath $statfile
$volnum = 1
$vols = (Get-SFVolumeForAccount -Accountid $accountid).VolumeName | where { $_ -like '*max*' }
[string]$maxprefix = $hostip + 'maxQoS-'
[string]$msg = Write-Output "*Create datastores with SIOC enabled"
$msg | Tee-Object -Append -FilePath $statfile

foreach ($vol in $vols) {
	[string]$ds = $maxprefix + $volnum
	$volpath = 'naa.' + ((Get-SFVolume -VolumeName $vol).Scsi_NAA_DeviceID)
	if(Get-Datastore -Name $ds   -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost  
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds  
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$volnum++
}
#>

Write-Output "*Create templates datastores " | Tee-Object -Append -FilePath $statfile
$volnum = 1
$vols = (Get-SFVolumeForAccount -Accountid $accountid).VolumeName | where { $_ -like '*vmw-template*' }
[string]$tmplprefix = $hostip + 'template-'
[string]$msg = Write-Output "*Create datastores with SIOC enabled"
$msg | Tee-Object -Append -FilePath $statfile

foreach ($vol in $vols) {
	[string]$ds = $tmplprefix + $volnum
	$volpath = 'naa.' + ((Get-SFVolume -VolumeName $vol).Scsi_NAA_DeviceID)
	if(Get-Datastore -Name $ds   -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $statfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost  
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds  
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
	$volnum++
}

# hard break if no datastores are created
$dscount = Get-Datastore  
if ($dscount.Length -lt 5) { 
	[string]$err = Write-Output "***** MAJOR FAIL: Datastores failed to create *****"
	$err | Tee-Object -Append -FilePath $errwarn 
	$err | Out-File -Append -FilePath $statfile
	break
}		
	
$dc = $clustername + 'datacenter'
$dscdefault = $hostip + $clustername + 'DSCdefault'
$dscmin = $hostip + $clustername + 'DSCmin'
$dscmax = $hostip + $clustername + 'DSCmax'
$template = $hostip + $clustername + 'DSCtemplates'
$location = Get-Datacenter   $dc

# create datastore cluster with default values / io load balance enabled / sdrs fully automated / default QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscdefault
$msg | Tee-Object -Append -FilePath $statfile
if(Get-DatastoreCluster -Name $dscdefault   -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscdefault
	$pass | Tee-Object -Append -FilePath $statfile		
} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $dscdefault    
	Set-DatastoreCluster -DatastoreCluster $dscdefault -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated    -ErrorAction Continue -ErrorVariable $err
	if($dcluster.Name -eq $dscdefault) {
		[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscdefault
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		[string]$err = Write-Output "FAIL: Datastore Cluster failed" $dscdefault
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
}

# do not create 3 QoS groups. instead, use SF powershell tools to set QoS on demand
# create datastore cluster with minimum values  / io load balance enabled / sdrs fully automated / min QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscmin
$msg | Tee-Object -Append -FilePath $statfile
if(Get-DatastoreCluster -Name $dscmin   -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscmin
	$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		$dcluster = New-DatastoreCluster -Location $location -Name $dscmin    
		Set-DatastoreCluster -DatastoreCluster $dscmin -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated    
		if($dcluster.Name -eq $dscdefault) {
			[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscmin
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore Cluster failed" $dscmin
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}

# create datastore cluster with maximum values  / io load balance enabled / sdrs fully automated / max QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscmax
$msg | Tee-Object -Append -FilePath $statfile
if(Get-DatastoreCluster -Name $dscmax   -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscmax
	$pass | Tee-Object -Append -FilePath $statfile		
	} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $dscmax   
	Set-DatastoreCluster -DatastoreCluster $dscmax -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated   
	if($dcluster.Name -eq $dscdefault) {
			[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscmax
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore Cluster failed" $dscmax
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
#>

# create templates datastore cluster with default values / io load balance enabled / sdrs fully automated / default QoS
[string]$msg = Write-Output "*Create datastore cluster" $template
$msg | Tee-Object -Append -FilePath $statfile
if(Get-DatastoreCluster -Name $template   -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $template
	$pass | Tee-Object -Append -FilePath $statfile		
} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $template    
	Set-DatastoreCluster -DatastoreCluster $template -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated    -ErrorAction Continue -ErrorVariable $err
	if($dcluster.Name -eq $dscdefault) {
		[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $template
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		[string]$err = Write-Output "FAIL: Datastore failed" $template
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $statfile
	}
}

# move default value datastores to default dsc
$dsdef = Get-Datastore   -Name '*default*'
foreach ($def in $dsdef) {
	if (Get-DatastoreCluster -Datastore $def   -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $def $dscdefault
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		$move = Move-Datastore -Destination $dscdefault   -Datastore $def
		if($move.Name -eq $def) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $def $dscdef
		$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $def $dscdef
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
}

#
# move min value datastores to min dsc
$dsmin = Get-Datastore   -Name ('*' + $minprefix + '*')
foreach ($min in $dsmin) {
	if (Get-DatastoreCluster -Datastore $min   -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $min $dscmin
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		$move = Move-Datastore -Destination $dscmin   -Datastore $min
		Set-Datastore -CongestionThresholdMillisecond 10   -Datastore $min
		if($move.Name -eq $min) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $min $dscmin
		$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $min $dscmin
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
}

$dsmax = Get-Datastore   -Name ('*' + $maxprefix + '*')
foreach ($max in $dsmax) {
	if (Get-DatastoreCluster -Datastore $max   -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $max $dscmax
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		$move = Move-Datastore -Destination $dscmax   -Datastore $max
		Set-Datastore -CongestionThresholdMillisecond 100   -Datastore $max
		if($move.Name -eq $max) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $max $dscmax
		$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $max $dscmax
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
}
#>

# move template datastores to default dsc
$tmpl = Get-Datastore   -Name ('*template*')
foreach ($tmp in $tmpl) {
	if (Get-DatastoreCluster -Datastore $tmp   -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $tmp $template
		$pass | Tee-Object -Append -FilePath $statfile		
	} else {
		$move = Move-Datastore -Destination $dscdefault   -Datastore $tmp
		if($move.Name -eq $def) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $tmp $template
		$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $tmp $tmpl
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi create datstores and datstore clusters ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
