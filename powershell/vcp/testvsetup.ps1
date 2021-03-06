[string]$mvip = '192.168.139.165'
[string]$sfadmin = 'admin'
[string]$sfpass = 'admin'
[string]$vcenter = '192.168.129.197'
[string]$vcadmin = 'admin'
[string]$vcpass = 'solidfire'
[string]$vmadmin = 'root'
[string]$vmpass = 'solidfire'
[string]$vmhost1='192.168.133.115'
[string]$vmhost2='192.168.129.142' #
[string]$vmhost3='192.168.129.209' #
[string]$vmhost4='192.168.129.174' #
[string]$vmhost5='192.168.129.10'  #
[string]$vmhost6='192.168.129.238'
# init powercli and SF powershell environments
.\Initialize-PowerCLIEnvironment.ps1
.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$toplocation = Get-Folder -NoRecursion -Server $vcenter

# setup top level 
$vcf1 = New-Folder -Confirm:$false -Name 'vc-folder1' -Location $toplocation
$vcf2 = New-Folder -Confirm:$false -Name 'vc-folder2' -Location $toplocation
$vcdc1 = New-Datacenter -Confirm:$false -Location $toplocation -Name 'vc-dc1'

# setup 2nd level 
$vcf1dc1 = New-Datacenter -Confirm:$false -Location 'vc-folder1' -Name 'vc-f1-dc1' 
$vcf1dc1cl1 = New-Cluster -Confirm:$false -Location 'vc-f1-dc1' -Name 'vc-f1-dc1-cl1'
$vcdc1cl1 = New-Cluster -Confirm:$false -Location 'vc-dc1' -Name 'vc-dc1-cl1'

# add hosts
##cannot add to root $tophost = Add-VMHost -Confirm:$false -Force -Location $toplocation -Password $vmpass -User $vmadmin -Name $vmhost1

$vcf2host = Add-VMHost -Confirm:$false -Force -Location 'vc-folder2' -Password $vmpass -User $vmadmin -Name $vmhost2
$vcf1host = Add-VMHost -Confirm:$false -Force -Location 'vc-f1-dc1-cl1' -Password $vmpass -User $vmadmin -Name $vmhost3
$vcf1dc1cl1host1 = Add-VMHost -Confirm:$false -Force -Location 'vc-f1-dc1-cl1' -Password $vmpass -User $vmadmin -Name $vmhost4
$vcf1dc1cl1host2 = Add-VMHost -Confirm:$false -Force -Location 'vc-dc1-cl1' -Password $vmpass -User $vmadmin -Name $vmhost5
$vcdc1cl1host1 = Add-VMHost -Confirm:$false -Force -Location 'vc-dc1-cl1' -Password $vmpass -User $vmadmin -Name $vmhost6
#$vcdc1cl1host2 = Add-VMHost -Confirm:$false -Force -Location $vcdc1cl1 -Password $vmpass -User $vmadmin -Name $vmhost7

Disconnect-SFCluster
Disconnect-VIServer -Confirm:$false
