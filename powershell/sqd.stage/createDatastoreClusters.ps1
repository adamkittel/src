param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("createDatastoreClusters.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

$clustername = ((Get-SFClusterInfo).name.split('-')[0])

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start ESXi create datstores and datstore clusters ##" 
$header | Tee-Object -Append -FilePath $checkfile

[string]$msg = Write-Output "*Rescan adapters"
$msg | Tee-Object -Append -FilePath $checkfile
Get-VMHostStorage -vmHost $esxhost -RescanAllHba -Server $vcenter

Write-Output "*Create default QoS value datastores with SIOC enabled" | Tee-Object -Append -FilePath $checkfile
$vols = Get-SFVolume -VolumeName "*default*"
$volnum = 1
$hostprefix = $esxhost.split('.')[3])
[string]$defprefix = $hostprefix + $clustername + 'defaultQoS-'

foreach ($vol in $vols) {
	[string]$ds = $defprefix + $volnum
	$volpath = 'naa.' + $vol.Scsi_NAA_DeviceID
	if(Get-Datastore -Name $ds -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost -Server $vcenter
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds -Server $vcenter
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
	$volnum++
}

Write-Output "*Create minimum QoS value datastores " | Tee-Object -Append -FilePath $checkfile
$vols = Get-SFVolume -VolumeName "*min*"
$volnum = 1
[string]$minprefix = $hostprefix + $clustername + 'minQoS-'
[string]$msg = Write-Output "*Create datastores with SIOC enabled"
$msg | Tee-Object -Append -FilePath $checkfile

foreach ($vol in $vols) {
	[string]$ds = $minprefix + $volnum
	$volpath = 'naa.' + $vol.Scsi_NAA_DeviceID
	if(Get-Datastore -Name $ds -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost -Server $vcenter
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds -Server $vcenter
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
	$volnum++
}

Write-Output "*Create maximum QoS value datastores " | Tee-Object -Append -FilePath $checkfile
$vols = Get-SFVolume -VolumeName "*max*"
$volnum = 1
[string]$maxprefix = $hostprefix + $hostprefix + $clustername + 'maxQoS-'
[string]$msg = Write-Output "*Create datastores with SIOC enabled"
$msg | Tee-Object -Append -FilePath $checkfile

foreach ($vol in $vols) {
	[string]$ds = $maxprefix + $volnum
	$volpath = 'naa.' + $vol.Scsi_NAA_DeviceID
	if(Get-Datastore -Name $ds -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost -Server $vcenter
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds -Server $vcenter
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
	$volnum++
}

Write-Output "*Create templates datastores " | Tee-Object -Append -FilePath $checkfile
$vols = Get-SFVolume -VolumeName "*tmpl*"
$volnum = 1
[string]$tmplprefix = $hostprefix + $clustername + 'template-'
[string]$msg = Write-Output "*Create datastores with SIOC enabled"
$msg | Tee-Object -Append -FilePath $checkfile

foreach ($vol in $vols) {
	[string]$ds = $tmplprefix + $volnum
	$volpath = 'naa.' + $vol.Scsi_NAA_DeviceID
	if(Get-Datastore -Name $ds -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $checkfile 
	} else {
		$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost -Server $vcenter
		Set-Datastore -StorageIOControlEnabled $true -Datastore $ds -Server $vcenter
		if($dstore.Name) {
			[string]$pass = Write-Output "PASS: Datastore Created: " $dstore.Name "CapacityGB: "$dstore.CapacityGB $dstore.State
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $ds
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
	$volnum++
}

# hard break if no datastores are created
$dscount = Get-Datastore -Server $vcenter
if ($dscount.Length -lt 3) { 
	[string]$err = Write-Output "***** MAJOR FAIL: Datastores failed to create *****"
	$err | Tee-Object -Append -FilePath $errwarn 
	$err | Out-File -Append -FilePath $checkfile
	break
}		
	
$dc = $hostprefix + $clustername + 'SFdatacenter'
$dscdefault = $hostprefix + $clustername + 'DSCdefault'
$dscmin = $hostprefix + $clustername + 'DSCmin'
$dscmax = $hostprefix + $clustername + 'DSCmax'
$template = $hostprefix + $clustername + 'DSCtemplates'
$location = Get-Datacenter -server $vcenter $dc

# create datastore cluster with default values / io load balance enabled / sdrs fully automated / default QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscdefault
$msg | Tee-Object -Append -FilePath $checkfile
if(Get-DatastoreCluster -Name $dscdefault -Server $vcenter -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscdefault
	$pass | Tee-Object -Append -FilePath $checkfile		
} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $dscdefault  -Server $vcenter 
	Set-DatastoreCluster -DatastoreCluster $dscdefault -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated  -Server $vcenter -ErrorAction Continue -ErrorVariable $err
	if($dcluster.Name -eq $dscdefault) {
		[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscdefault
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		[string]$err = Write-Output "FAIL: Datastore Cluster failed" $dscdefault
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
}

# create datastore cluster with minimum values  / io load balance enabled / sdrs fully automated / min QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscmin
$msg | Tee-Object -Append -FilePath $checkfile
if(Get-DatastoreCluster -Name $dscmin -Server $vcenter -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscmin
	$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		$dcluster = New-DatastoreCluster -Location $location -Name $dscmin  -Server $vcenter 
		Set-DatastoreCluster -DatastoreCluster $dscmin -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated  -Server $vcenter 
		if($dcluster.Name -eq $dscdefault) {
			[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscmin
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore Cluster failed" $dscmin
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}

# create datastore cluster with maximum values  / io load balance enabled / sdrs fully automated / max QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscmax
$msg | Tee-Object -Append -FilePath $checkfile
if(Get-DatastoreCluster -Name $dscmax -Server $vcenter -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscmax
	$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $dscmax -Server $vcenter 
	Set-DatastoreCluster -DatastoreCluster $dscmax -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated -Server $vcenter 
	if($dcluster.Name -eq $dscdefault) {
			[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscmax
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore Cluster failed" $dscmax
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}

# create templates datastore cluster with default values / io load balance enabled / sdrs fully automated / default QoS
[string]$msg = Write-Output "*Create datastore cluster" $template
$msg | Tee-Object -Append -FilePath $checkfile
if(Get-DatastoreCluster -Name $template -Server $vcenter -ErrorAction SilentlyContinue) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $template
	$pass | Tee-Object -Append -FilePath $checkfile		
} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $template  -Server $vcenter 
	Set-DatastoreCluster -DatastoreCluster $template -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated  -Server $vcenter -ErrorAction Continue -ErrorVariable $err
	if($dcluster.Name -eq $dscdefault) {
		[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $template
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		[string]$err = Write-Output "FAIL: Datastore failed" $template
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
	}
}

# move default value datastores to default dsc
$dsdef = Get-Datastore -Server $vcenter -Name ($defprefix + '*')
foreach ($def in $dsdef) {
	if (Get-DatastoreCluster -Datastore $def -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $def $dscdefault
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		$move = Move-Datastore -Destination $dscdefault -Server $vcenter -Datastore $def
		if($move.Name -eq $def) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $def $dscdef
		$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $def $dscdef
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
}

# move min value datastores to min dsc
$dsmin = Get-Datastore -Server $vcenter -Name ($minprefix + '*')
foreach ($min in $dsmin) {
	if (Get-DatastoreCluster -Datastore $min -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $min $dscmin
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		$move = Move-Datastore -Destination $dscmin -Server $vcenter -Datastore $min
		Set-Datastore -CongestionThresholdMillisecond 10 -Server $vcenter -Datastore $min
		if($move.Name -eq $min) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $min $dscmin
		$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $min $dscmin
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
}

$dsmax = Get-Datastore -Server $vcenter -Name ($maxprefix + '*')
foreach ($max in $dsmax) {
	if (Get-DatastoreCluster -Datastore $max -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $max $dscmax
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		$move = Move-Datastore -Destination $dscmax -Server $vcenter -Datastore $max
		Set-Datastore -CongestionThresholdMillisecond 100 -Server $vcenter -Datastore $max
		if($move.Name -eq $max) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $max $dscmax
		$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $max $dscmax
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
}

# move default value datastores to default dsc
$tmpl = Get-Datastore -Server $vcenter -Name ($tmplprefix + '*')
foreach ($tmp in $tmpl) {
	if (Get-DatastoreCluster -Datastore $tmp -Server $vcenter -ErrorAction SilentlyContinue) {
		[string]$pass = Write-Output "PASS: Datastore already in datastore cluster: " $tmp $template
		$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		$move = Move-Datastore -Destination $dscdefault -Server $vcenter -Datastore $tmp
		if($move.Name -eq $def) {
		[string]$pass = Write-Output "PASS: Datastore moved to datastore cluster: " $tmp $template
		$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore not moved to datastore cluster: " $tmp $tmpl
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
}

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi create datstores and datstore clusters ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
