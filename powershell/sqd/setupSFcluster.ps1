param(
	[String]$mvip='192.168.139.165',
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$maxprefix='max',
	[string]$minprefix='min',
	[string]$defprefix='def',
	[string]$rdmprefix='rdm'
)

###################################
# set up networking for iscsi
# set up software iscsi adapter
#
# usage: .ps1 
# -mvip
# -sfadmin (default:admin)
# -sfpass  (default: admin)
# -maxprefix (max qos volumes prefix. default: max)
# -defprefix (default qos volumes prefix. default: def)
# -minprefix (min qos volumes prefix. default: min)
# -defprefix (rdm qos volumes prefix. default: rdm)

Start-Transcript -Append -Force -NoClobber -Path "setupSFcluster.log"
# 
## connect to cluster. exit if fail
#Connect-SFCluster -UserName $sfadmin -Password $sfpass -Target $mvip
Connect-SFCluster -UserName $sfadmin -Target $mvip

Write-Host "########## Start SFcluster setup ##########"

# create account (add VAG after esxi iscsi setup
New-SFAccount -InitiatorSecret solidfire1234 -TargetSecret 1234solidfire -UserName vmw -Verbose
$sfacc = Get-SFAccount

# setup min QoS value volumes
$num=1
1..10 | foreach {
	try {
		New-SFVolume -AccountID $sfacc.AccountID -BurstIOPS 100 -Enable512e $true -MaxIOPS 100 -MinIOPS 100 -Name $minprefix -TotalSize 100000000000 -Verbose 
	} catch { Write-Host -ForegroundColor White -BackgroundColor Red "FAILED: creating volume" }
	$num++
}

# setup max QoS value volumes
$num=1
1..10 | foreach {
	try {
		New-SFVolume -AccountID $sfacc.AccountID -BurstIOPS 100000 -Enable512e $true -MaxIOPS 100000 -MinIOPS 15000 -Name $maxprefix$num -TotalSize 100000000000 -Verbose
	} catch { Write-Host -ForegroundColor White -BackgroundColor Red "FAILED: creating volume" }
	$num++
}

# setup default QoS value volumes
$num=1
1..10 | foreach {
	try {
		New-SFVolume -AccountID $sfacc.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $defprefix$num -TotalSize 100000000000 -Verbose
	} catch { Write-Host -ForegroundColor White -BackgroundColor Red "FAILED: creating volume" }
	$num++
}


# setup rdm volumes
$num=1
1..10 | foreach {
	try {
		New-SFVolume -AccountID $sfacc.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 50 -Name $rdmprefix$num -TotalSize 100000000000 -Verbose
	} catch { Write-Host -ForegroundColor White -BackgroundColor Red "FAILED: creating volume" }
	$num++
}

Write-Host "########## Start SFcluster setup ##########"
Stop-Transcript