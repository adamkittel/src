param(	
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$vmnic1='vmnic1',
	[string]$vmnic2='vmnic2'
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("swiscsiSetup.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start ESXi software iscsi Setup ##" 
$header | Tee-Object -Append -FilePath $checkfile

$vss = 'vSwitchSF'

## create vss vSwitchSF
if(Get-VirtualSwitch -Server $vcenter -VMHost $esxhost -Name $vss -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists" $vss
	$exists | Tee-Object -Append -FilePath $checkfile
	} else {	
	Write-Output "*Create vSwitchSF" | Tee-Object -Append -FilePath $checkfile
	New-VirtualSwitch -Mtu 9000 -Nic $vmnic1,$vmnic2 -Name $vss -VMHost $esxhost -Server $vcenter
}

## add iscsi portgroups, vmkernel ports vmk1 & vmk2, set nic failover
if(Get-VirtualPortGroup -Server $vcenter -VMHost $esxhost -Name 'SF1' -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists: Portgroup SF1"
	$exists | Tee-Object -Append -FilePath $checkfile
	} else {	
	Write-Output "*Create Portgroup SF1" | Tee-Object -Append -FilePath $checkfile
	New-VirtualPortGroup -Name 'SF1'  -VirtualSwitch $vss -Server $vcenter
	New-VMHostNetworkAdapter -VMHost $esxhost -PortGroup 'SF1' -VirtualSwitch $vss -Mtu 9000 -Server $vcenter
	Get-VirtualPortGroup -VMHost $esxhost -VirtualSwitch $vss -Name 'SF1' -Server $vcenter| Get-NicTeamingPolicy -Server $vcenter |Set-NicTeamingPolicy -MakeNicActive $vmnic1 -MakeNicUnused $vmnic2
}

if(Get-VirtualPortGroup -Server $vcenter -VMHost $esxhost -Name 'SF2' -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists: Portgroup SF2"
	$exists | Tee-Object -Append -FilePath $checkfile
	} else {	
	Write-Output "*Create Portgroup SF2" | Tee-Object -Append -FilePath $checkfile
	New-VirtualPortGroup -Name 'SF2'  -VirtualSwitch $vss -Server $vcenter
	New-VMHostNetworkAdapter -VMHost $esxhost -PortGroup 'SF2' -VirtualSwitch $vss -Mtu 9000 -Server $vcenter
	Get-VirtualPortGroup -VMHost $esxhost -VirtualSwitch $vss -Name 'SF2' -Server $vcenter| Get-NicTeamingPolicy -Server $vcenter |Set-NicTeamingPolicy -MakeNicActive $vmnic2 -MakeNicUnused $vmnic1 
}

## enable software iscsiadapter
## bind vmkernel ports
## add svip target
if(((Get-VMHostStorage -Server $vcenter -VMHost $esxhost).SoftwareIScsiEnabled) -eq 'True' ) {
	[string]$exists = Write-Output "PASS: Software iscsi adapter already enabled. Rescan adapters"
	$exists | Tee-Object -Append -FilePath $checkfile
	Get-VMHostStorage -RescanAllHba  -VMHost $esxhost -Server $vcenter
	} else {	
	Write-Output "*Setup software iscsi, add svip and rescan" | Tee-Object -Append -FilePath $checkfile
	Get-VMHostStorage -VMHost $esxhost -Server $vcenter | Set-VMHostStorage -SoftwareIScsiEnabled $true
	$vmhba = Get-VMHostHba -VMHost $esxhost -Type iscsi -Server $vcenter | where {$_.Status -like 'online'}| %{$_.Device}
	$esxcli = Get-EsxCli -VMHost $esxhost -Server $vcenter
	$esxcli.iscsi.networkportal.add($vmhba, $false, 'vmk1')
	$esxcli.iscsi.networkportal.add($vmhba, $false, 'vmk2')
	New-IScsiHbaTarget -IScsiHba $vmhba -Address $svip -Type Send -Server $vcenter
	Set-VMHostHba -IScsiName "iqn.1998-01.com.vmware:$esxhost" -IScsiHba $vmhba  -Server $vcenter
	Get-VMHostStorage -RescanAllHba  -VMHost $esxhost -Server $vcenter
}

#check for SF targets
[string]$msg = Write-Output "*Verify SF targets"
$msg | Tee-Object -Append -FilePath $checkfile
$vols = Get-ScsiLun -VmHost $esxhost -CanonicalName 'naa.6f47*' -Server $vcenter

if(! $vols) {
		[string]$err = Write-Output "********* MAJOR FAIL: No volumes discovered *********"
		$err | Tee-Object -Append -FilePath $errwarn 
		$err | Out-File -Append -FilePath $checkfile
		break
		} else { 
			foreach ($vol in $vols) {
			$volpath = Get-ScsiLunPath -ScsiLun $vol
			if($volpath.State -eq 'Active') {
			[string]$pass = Write-Output "PASS: " $volpath.State $vol.MultipathPolicy $vol $volpath.SanID
			$pass | Tee-Object -Append -FilePath $checkfile 
			} else {
			[string]$err = Write-Output "FAIL: Volume not active" $volpath.State $vol $volpath.SanID 
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
}
	
[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End ESXi software iscsi Setup ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 
