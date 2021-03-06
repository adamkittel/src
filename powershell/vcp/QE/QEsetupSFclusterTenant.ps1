param(
	[string]$sfadmin='admin',
	[string]$sfpass='admin',
	[Parameter(Mandatory=$true)]
	[string]$mvip,
    [Parameter(Mandatory=$true)]
    [string]$esxhost,
    [string]$note = 'Green'
)

# init powercli and SF powershell environments
.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -Password $sfpass -Target $mvip -ErrorAction Stop

# setup log files and get global variables
[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -scriptname $scriptname -note $note

# start transcript and mark script start
Start-Transcript -Append -Force -NoClobber -Path $transcript
[string]$header = (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + ' Start ' + $scriptname 
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

# make volume function
function makevols ([string]$pre) { 
		[string]$vol = $hostip + $pre
        Write-Output ("Create Volume " + $vol) 
		$newvol = New-SFVolume -AccountID $acnt.AccountID -BurstIOPS $burstiops -Enable512e $true -MaxIOPS $maxiops -MinIOPS $miniops -Name $vol -GB 4000 -ErrorVariable red  
        redcheck($red)
        $newvol | Format-Table -Property VolumeID,name,ScsiNAADeviceID,Status | Tee-Object -Append -FilePath $statfile
}

# create account 
[string]$hostip = $esxhost.split('.')[3]
$account = $hostip + 'account'
$acnt = Get-SFAccount -UserName $account -ErrorVariable red
if(! $acnt) { 
    [string]$msg =  "Create account: " + $account
	$msg | Tee-Object -Append -FilePath $statfile	
	New-SFAccount -InitiatorSecret solidfire1234 -TargetSecret 1234solidfire -UserName $account -ErrorVariable red  | Format-Table -AutoSize | Tee-Object -Append -FilePath $statfile
    redcheck($red)
}

# add cluster admin with reporting access
New-SFClusterAdmin -UserName ($hostip + "ClusterID") -Password "solidfire" -Access "Reporting" -Confirm:$false -ErrorVariable red  | Format-Table -AutoSize | Tee-Object -Append -FilePath $statfile
redcheck($red)

# create VAG
$vagname = $hostip + 'VAG'
###$initiator = "iqn.1998-01.com.vmware:host" + $hostip
$initiator = "iqn.1998-01.com.vmware:hostint3"
###
Write-Output "Create Volume Access Group: " + $vagname | Tee-Object -Append -FilePath $statfile	
New-SFVolumeAccessGroup -Name $vagname -ErrorVariable red  | Format-Table -AutoSize | Tee-Object -Append -FilePath $statfile
redcheck($red)
Add-SFInitiatorToVolumeAccessGroup -VolumeAccessGroupID (Get-SFVolumeAccessGroup -VolumeAccessGroupName $vagname).VolumeAccessGroupID -Initiators $initiator -ErrorVariable red  | Format-Table -AutoSize | Tee-Object -Append -FilePath $statfile
redcheck($red)

# make volume types and default QoS settings
$voltypes = 'min','max','def','template'
foreach ($voltype in $voltypes) {
	switch ($voltype) {
		"min" {
			[string]$prefix = 'minQOS'
			[string]$burstiops = '100'
			[string]$maxiops = '100'
			[string]$miniops = '100'
			makevols $prefix 
		}
		"max" {
			[string]$prefix = 'maxQOS'
			[string]$burstiops = '100000'
			[string]$maxiops = '100000'
			[string]$miniops = '15000'
			makevols $prefix 
		}
		"def" {
			[string]$prefix = 'defaultQOS'
			[string]$burstiops = '15000'
			[string]$maxiops = '15000'
			[string]$miniops = '100'
			makevols $prefix 
		}
        "template" {
            [string]$prefix = 'template'
			[string]$burstiops = '15000'
			[string]$maxiops = '15000'
			[string]$miniops = '100'
			makevols $prefix 
        }
	}
}			


# add volumes to VAG
Write-Output "Add volumes to VAG: " + $vag.Name + ' ' + $vag.VolumeAccessGroupID | Tee-Object -Append -FilePath $statfile 
$volids = (Get-SFVolume -AccountID $acct.AccountID).VolumeID 
Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeID $volids -ErrorVariable red  | Format-Table -AutoSize | Tee-Object -Append -FilePath $statfile
redcheck($red)

# esxi host rescan
Get-VMHostStorage -RescanAllHba -VMHost $esxhost

<# code to deal with vmware iscsi adpater if needed in the future
## enable software iscsiadapter
## bind vmkernel ports
## add svip target
if(((Get-VMHostStorage -Server $vcenter -VMHost $esxhost).SoftwareIScsiEnabled) -eq 'True' ) {
	Write-Output "PASS: Software iscsi adapter already enabled. Rescan adapters" | Tee-Object -Append -FilePath $statfile
	Get-VMHostStorage -RescanAllHba  -VMHost $esxhost -Server $vcenter
	} else {	
	Write-Output "*Setup software iscsi, add svip and rescan" | Tee-Object -Append -FilePath $statfile
	Get-VMHostStorage -VMHost $esxhost -Server $vcenter | Set-VMHostStorage -SoftwareIScsiEnabled $true
	$vmhba = Get-VMHostHba -VMHost $esxhost -Type iscsi -Server $vcenter | where {$_.Status -like 'online'}| %{$_.Device}
	$esxcli = Get-EsxCli -VMHost $esxhost -Server $vcenter
	$esxcli.iscsi.networkportal.add($vmhba, $false, 'vmk1')
	$esxcli.iscsi.networkportal.add($vmhba, $false, 'vmk2')
	New-IScsiHbaTarget -IScsiHba $vmhba -Address $svip -Type Send -Server $vcenter
	Set-VMHostHba -IScsiName "iqn.1998-01.com.vmware:$esxhost" -IScsiHba $vmhba  -Server $vcenter
	Get-VMHostStorage -RescanAllHba  -VMHost $esxhost -Server $vcenter
}
#>

[string]$footer = '`n`n## ' + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + ' End ' + $scriptname + ' ##'
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
Disconnect-SFCluster -ErrorVariable red
redcheck($red)
