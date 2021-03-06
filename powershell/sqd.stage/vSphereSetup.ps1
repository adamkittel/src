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

logSetup("vSphereSetup.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

$clustername = ((Get-SFClusterInfo).name.split('-')[0])
$hostprefix = $esxhost.split('.')[3]

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start vSphere setup ##" 
$header | Tee-Object -Append -FilePath $checkfile

## set root folder
[string]$location = Get-Folder -NoRecursion -Server $vcenter
[string]$dc = $hostprefix + $clustername + 'SFdatacenter'
[string]$cl = $hostprefix + $clustername + 'SFcluster'

## create datacenter. ignore error if exists. 
if(Get-Datacenter -Server $vcenter -Name $dc -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists" $dc
	$exists | Tee-Object -Append -FilePath $checkfile
	} else {	
	Write-Output "*Create Datacenter" | Tee-Object -Append -FilePath $checkfile
	New-Datacenter -Name $dc -Location $location  -Server $vcenter 
}

## create cluster. do not enable ha or drs. ignore error if exists
if(Get-Cluster -Server $vcenter -Name $cl -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists" $cl
	$exists | Tee-Object -Append -FilePath $checkfile
	} else {	
	Write-Output "*Create Cluster" | Tee-Object -Append -FilePath $checkfile
	New-Cluster -Location $dc -Name $cl  -Server $vcenter
}

## add esxi host. if in maint mode, set to connected
if(Get-VMHost -Server $vcenter -Name $esxhost -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists" $esxhost
	$exists | Tee-Object -Append -FilePath $checkfile
	} else {	
	Write-Output "*Add esxi host" | Tee-Object -Append -FilePath $checkfile
	Add-VMHost -Force -Location (Get-Cluster -Server $vcenter -Name $cl) -Server $vcenter -Name $esxhost -Password $esxpass -User $esxadmin
	Set-VMHost -Server $vcenter -VMHost $esxhost -State Connected
}

# add initiator to volume access group
Write-Output "*Add initiator to volume access group " | Tee-Object -Append -FilePath $checkfile
$hba = Get-VMHostHba -VMHost $esxhost -Type iscsi -Server $vcenter | Where-Object { $_.Model -eq "iSCSI Software Adapter" }
$iqn = $hba.iscsiname 
$volid = (Get-SFVolume).VolumeID
$vmwVAG = $clustername + 'VAG'
$vag = Get-SFVolumeAccessGroup -VolumeAccessGroupName $vmwVAG
Set-SFVolumeAccessGroup -Initiators $iqn -VolumeAccessGroupID $vag.VolumeAccessGroupID 

<#
#find and add vm's for clone ops
$dss = Get-Datastore -Server $vcenter
foreach($ds in $dss) {
   # Set up Search for .VMX Files in Datastore
   $dds = Get-Datastore -Name $ds | %{Get-View $_.Id}
   $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
   $searchSpec.matchpattern = "*.vmx"
   $dsBrowser = Get-View $ds.browser
   $datastorePath = "[" + $ds.Summary.Name + "]"
 
   # Find all .VMX file paths in Datastore, filtering out ones with .snapshot (Useful for NetApp NFS)
   $searchResult = $dsBrowser.SearchDatastoreSubFolders($datastorePath, $searchSpec) | where {$_.FolderPath -notmatch ".snapshot"} | %{$_.FolderPath + ($_.File | select Path).Path}
 
   #Register all .vmx Files as VMs on the datastore
   foreach($VMXFile in $searchResult) {
      New-VM -VMFilePath $VMXFile -VMHost $ESXHost -Location $VMFolder -RunAsync
   }
}

# find and add templates

foreach($ds in $dss) {
   # Set up Search for .VMX Files in Datastore
   $dds = Get-Datastore -Name $ds | %{Get-View $_.Id}
   $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
   $searchSpec.matchpattern = "*.vmtx"
   $dsBrowser = Get-View $ds.browser
   $datastorePath = "[" + $ds.Summary.Name + "]"
 
   # Find all .VMX file paths in Datastore, filtering out ones with .snapshot (Useful for NetApp NFS)
   $searchResult = $dsBrowser.SearchDatastoreSubFolders($datastorePath, $searchSpec) | where {$_.FolderPath -notmatch ".snapshot"} | %{$_.FolderPath + ($_.File | select Path).Path}
 
   #Register all .vmx Files as VMs on the datastore
   foreach($VMXFile in $searchResult) {
      New-VM -VMFilePath $VMXFile -VMHost $ESXHost -Location $VMFolder -RunAsync
   }
}
#>


[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End vSphere Setup ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 

	
