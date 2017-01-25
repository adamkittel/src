param(
	#[Parameter(Mandatory=$true)]
	[string]$vcenter = '192.168.129.228',
	[String]$vcadmin='administrator@solidfire.eng',
	[String]$vcpass='solidF!r3',
	#[Parameter(Mandatory=$true)]
	[string]$esxhost = '192.168.133.126',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$dsname = 'HostIntInfra',
	[Parameter(Mandatory=$true)]
	[string]$vcname
)

.\Initialize-PowerCLIEnvironment.ps1

Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

 #$xml = [XML](Get-Content 'c:\solidfire\conf\5.5-vSphereDeploy.xml')
 $xml = [XML](Get-Content 'z:\src\powershell\vcp\HostInt_lab\5.5-vSphereDeploy.xml')
 $VMnetwork = $xml.Masterconfig.config.MgmtNetwork
 $vcenteruser = $xml.Masterconfig.vcenterconfig.vcusername
 $vcenterpassword = $xml.Masterconfig.vcenterconfig.vcpassword
 
 #Ignore selfsigned cert
 #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
 
  #Load the ovf specific configuration in the $ovfconfig file
 $vcsalocation = 'c:\solidfire\ova\VMware-vCenter-Server-Appliance-5.5.0.20400-2442330_OVF10.ova'
 $ovfconfig = Get-OvfConfiguration $vcsalocation
 
 #Populate the members properties of the ovf file.
 $ovfconfig.common.vami.hostname.Value = $vcname
 $ovfconfig.IpAssignment.IpProtocol.Value = 'IPv4'
 $ovfconfig.NetworkMapping.Network_1.Value = $VMnetwork
 
 #Importing the vapp now
 Write-host "Importing vApp..."
 Import-vapp -Source $vcsalocation -OVFConfiguration $ovfconfig -Name $vcname -VMHost $esxhost -Datastore $dsname -Diskstorageformat thin
 
  #Poweron the vm
 Write-Host "Powering on vcsa"
 Start-vm $vcname | Wait-Tools
 
 #Configuring VCSA appliance now..
 Write-Host "Configuring vcsa appliance now.."
 Invoke-VMScript -VM $vcsname -ScriptText "/usr/sbin/vpxd_servicecfg eula accept && /usr/sbin/vpxd_servicecfg db write embedded && /usr/sbin/vpxd_servicecfg sso write embedded && /usr/sbin/vpxd_servicecfg service start && /usr/sbin/vpxd_servicecfg timesync write ntp time.rackspace.com" -ScriptType Bash -GuestUser 'root' -GuestPassword 'vmware'
 sleep(30)
 Restart-VMGuest -VM $vcname -Confirm:$false
 Write-Host "The guest configuration is now complete and it is restarting.. please wait a few minutes before all services are started..."
 
 # deploy esxi vm
New-VM -Confirm:$false -Datastore $dsname -VM 'esxTemplate' -Name $esxvm -VMHost $esxhost
Set-CDDrive -CD (Get-CDDrive -vm $esxvm) -IsoPath "[HostIntInfra]\5.5-vm.iso" -StartConnected 1 -Confirm:$false
Start-VM -Confirm:$false -VM $esxvm -RunAsync

Disconnect-VIServer -Confirm:$false
 