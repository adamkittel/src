param(
	[String]$vcenter='192.168.129.66',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost='192.168.133.115',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	[string]$vmnic1='vmnic0',
	[string]$vmnic2='vmnic1',
	[string]$svip='10.10.8.165'
)

###################################
# set up networking for iscsi
# set up software iscsi adapter
#
# usage: .ps1 
# -vcenter [name/ip] 
# -vcadmin [vcenter administrator (default: admin)] 
# -vcpass [vc adminsistrator password (default: solidfire)]
# -esxhost [name/ip]
# -esxadmin [esxi administrator (default: root)]
# -esxpass [esxi administrator password (default: solidfire)]
# -vmnic1 [default: vmnic0]
# -vmnic2 [default: vmnic1]
# -svip 
# start the run log
$vss = 'vSitchSF'
Start-Transcript -Append -Force -NoClobber -Path "ESXswiscsiSetup.log" 
# 
## connect to vcenter. exit if fail
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

Write-Host "########## Start ESXi software iscsi Setup ##########"

## create vss vSwitchSF
Write-Host "create vswitch vSwitchSF"
try { 
New-VirtualSwitch -Mtu 9000 -Nic $vmnic1,$vmnic2 -Name $vss -VMHost $esxhost
} catch { Write-Host "New-VirtualSwitch failed. Exists?" }

## add iscsi portgroups, vmkernel ports vmk1 & vmk2, set nic failover
Write-Host "add iscsi portgroups, vmkernel ports vmk1 & vmk2, set nic failover"
try {
$sf1 = New-VirtualPortGroup -ErrorAction Stop -Name "SF1" -Verbose -VirtualSwitch $vss
$sf2 = New-VirtualPortGroup -ErrorAction Stop -Name "SF2" -Verbose -VirtualSwitch $vss

New-VMHostNetworkAdapter -VMHost $esxhost -PortGroup $sf1 -VirtualSwitch $vss -Mtu 9000 -Verbose
New-VMHostNetworkAdapter -VMHost $esxhost -PortGroup $sf2 -VirtualSwitch $vss -Mtu 9000 -Verbose

Get-VirtualPortGroup -VMHost $esxhost -VirtualSwitch $vss -Name $sf1 | Get-NicTeamingPolicy |Set-NicTeamingPolicy -MakeNicActive $vmnic1 -MakeNicUnused $vmnic2 -Verbose
Get-VirtualPortGroup -VMHost $esxhost -VirtualSwitch $vss -Name $sf2 | Get-NicTeamingPolicy |Set-NicTeamingPolicy -MakeNicActive $vmnic2 -MakeNicUnused $vmnic1 -Verbose
} catch { Write-Host "New-VirtualPortGroup failed. Exists?" }

## enable software iscsiadapter
## bind vmkernel ports
## add svip target
Write-Host "enable software iscsiadapter. bind vmkernel ports. add svip target"
try {
Get-VMHostStorage -VMHost $esxhost | Set-VMHostStorage -SoftwareIScsiEnabled $true -Verbose
$vmhba = Get-VMHostHba -VMHost $esxhost -Type iscsi | where {$_.Status -like 'online'}| %{$_.Device}

#Sets up PowerCLI to be able to access esxcli commands
$esxcli = Get-EsxCli -VMHost $esxhost

#Binds VMKernel ports to the iSCSI Software Adapter HBA
$vmk1 = 'vmk1'
$vmk2 = 'vmk2'
$esxcli.iscsi.networkportal.add($vmhba, $false, $vmk1)
$esxcli.iscsi.networkportal.add($vmhba, $false, $vmk2)

New-IScsiHbaTarget -IScsiHba $vmhba -Address $svip -Verbose -ChapName "solidfire" -ChapPassword "solidfire1234" -ChapType Preferred -Type Send 
Set-VMHostHba -IScsiName "iqn.1998-01.com.vmware:solidfire" -IScsiHba $vmhba -Verbose
Get-VMHostStorage -RescanAllHba -Verbose
Get-IScsiHbaTarget -Address $svip -Type Send -IScsiHba $vmhba
} catch { Write-Host "iscsi setup failed. already exists?" }


Write-Host "########## End vSphere Setup ##########"
Stop-Transcript 