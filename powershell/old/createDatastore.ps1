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

logSetup("createDatastore.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start ESXi create datstores and datstore clusters ##" 
$header | Tee-Object -Append -FilePath $checkfile

[string]$msg = Write-Output "*Rescan adapters"
$msg | Tee-Object -Append -FilePath $checkfile
Get-VMHostStorage -vmHost $esxhost -RescanAllHba -Server $vcenter

$vols = Get-ScsiLun -VmHost $esxhost -CanonicalName "naa.6f47*" -Server $vcenter
$volnum = 1

# create datastores with sioc enabled
[string]$msg = Write-Output "*Create datastores with SIOC enabled"
$msg | Tee-Object -Append -FilePath $checkfile

1..60 | foreach {
	$volpath = $vols[$volnum]
	if (($volnum -ge 1)  -and ($volnum -le 10)) { $prefix = 'def' }
	if (($volnum -ge 11) -and ($volnum -le 20)) { $prefix = 'min' }
	if (($volnum -ge 21) -and ($volnum -le 30)) { $prefix = 'max' } 
	if (($volnum -ge 31) -and ($volnum -le 40)) { $prefix = 'linkedClones' } 
	if (($volnum -ge 41) -and ($volnum -le 50)) { $prefix = 'fullClones' } 
	if (($volnum -ge 51) -and ($volnum -le 60)) { $prefix = 'templates' }
	
	[string]$ds = $prefix + '-' + $volnum
	if(Get-Datastore -Name $ds -Server $vcenter) {
		[string]$pass = Write-Output "PASS: Datastore already exists" $ds
		$pass | Tee-Object -Append -FilePath $checkfile 
		} else {
			$dstore = New-Datastore -Vmfs -Name $ds -Path $volpath -FileSystemVersion 5 -VMHost $esxhost -Server $vcenter
			Set-Datastore -StorageIOControlEnabled $true -Datastore $prefix'-'$volnum -Server $vcenter
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
	
$dc = "SFdatacenter"
$dscdefault = "DSCdefault"
$dscmin = "DSCmin"
$dscmax = "DSCmax"
$location = Get-Datacenter -server $vcenter SFDatacenter

# create datastore cluster with default values / io load balance enabled / sdrs fully automated / default QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscdefault
$msg | Tee-Object -Append -FilePath $checkfile
if(Get-DatastoreCluster -Name $dscdefault -Server $vcenter) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscdefault
	$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $dscdefault  -Server $vcenter 
	Set-DatastoreCluster -DatastoreCluster $dscdefault -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated  -Server $vcenter -ErrorAction Continue -ErrorVariable $err
	if($dcluster.Name -eq $dscdefault) {
			[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscdefault
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $dsprefix$volnum
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}

# create datastore cluster with minimum values  / io load balance enabled / sdrs fully automated / min QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscmin
$msg | Tee-Object -Append -FilePath $checkfile
if(Get-DatastoreCluster -Name $dscmin -Server $vcenter) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscmin
	$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
		$dcluster = New-DatastoreCluster -Location $location -Name $dscmin  -Server $vcenter 
		Set-DatastoreCluster -DatastoreCluster $dscmin -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated  -Server $vcenter 
		if($dcluster.Name -eq $dscdefault) {
			[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscmin
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $dscmin
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}

# create datastore cluster with maximum values  / io load balance enabled / sdrs fully automated / max QoS
[string]$msg = Write-Output "*Create datastore cluster" $dscmax
$msg | Tee-Object -Append -FilePath $checkfile
if(Get-DatastoreCluster -Name $dscmax -Server $vcenter) {
	[string]$pass = Write-Output "PASS: Datastore Cluster already exists: " $dscmax
	$pass | Tee-Object -Append -FilePath $checkfile		
	} else {
	$dcluster = New-DatastoreCluster -Location $location -Name $dscmax -Server $vcenter 
	Set-DatastoreCluster -DatastoreCluster $dscmax -IOLoadBalanceEnabled $true -SdrsAutomationLevel FullyAutomated -Server $vcenter 
	if($dcluster.Name -eq $dscdefault) {
			[string]$pass = Write-Output "PASS: Datastore Cluster Created: " $dscmax
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: Datastore failed" $dscmax
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}


# move default value datastores to default dsc
$dsdef = Get-Datastore -Server $vcenter -Name 'def*'
foreach ($def in $dsdef) {
	if (Get-DatastoreCluster -Datastore $def -Server $vcenter) {
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
$dsmin = Get-Datastore -Server $vcenter -Name 'min*'
foreach ($min in $dsmin) {
	if (Get-DatastoreCluster -Datastore $min -Server $vcenter) {
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

$dsmax = Get-Datastore -Server $vcenter -Name 'max*'
foreach ($max in $dsmax) {
	if (Get-DatastoreCluster -Datastore $max -Server $vcenter) {
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

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi create datstores and datstore clusters ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
