param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

# init powercli and SF powershell environments
.\Initialize-PowerCLIEnvironment.ps1
.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

## set root folder, datacenter and cluster names
[string]$location = Get-Folder -NoRecursion -Server $vcenter
[string]$dc = $hostprefix + $clustername + 'datacenter'
[string]$cl = $hostprefix + $clustername + 'cluster'

## create datacenter. ignore error if exists. 
if(Get-Datacenter -Server $vcenter -Name $dc -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists" $dc
	$exists | Tee-Object -Append -FilePath $statfile
	} else {	
	Write-Output "*Create Datacenter" | Tee-Object -Append -FilePath $statfile
	New-Datacenter -Name $dc -Location $location  -Server $vcenter 
}

## create cluster. do not enable ha or drs. ignore error if exists
if(Get-Cluster -Server $vcenter -Name $cl -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists" $cl
	$exists | Tee-Object -Append -FilePath $statfile
	} else {	
	Write-Output "*Create Cluster" | Tee-Object -Append -FilePath $statfile
	New-Cluster -Location $dc -Name $cl  -Server $vcenter
}

## add esxi host. if in maint mode, set to connected
if(Get-VMHost -Server $vcenter -Name $esxhost -ErrorAction SilentlyContinue) {
	[string]$exists = Write-Output "PASS: Already exists" $esxhost
	$exists | Tee-Object -Append -FilePath $statfile
	} else {	
	Write-Output "*Add esxi host" | Tee-Object -Append -FilePath $statfile
	Add-VMHost -Force -Location (Get-Cluster -Server $vcenter -Name $cl) -Server $vcenter -Name $esxhost -Password $esxpass -User $esxadmin
	Set-VMHost -Server $vcenter -VMHost $esxhost -State Connected
}

# add initiator to volume access group
[string]$hostip = $esxhost.split('.')[3]
Write-Output "*Add initiator to volume access group " | Tee-Object -Append -FilePath $statfile
$hba = Get-VMHostHba -VMHost $esxhost -Type iscsi -Server $vcenter | Where-Object { $_.Model -eq "iSCSI Software Adapter" }
$volid = (Get-SFVolume).VolumeID
$vmwVAG = $hostip + 'VAG'
$vag = Get-SFVolumeAccessGroup -VolumeAccessGroupName $vmwVAG
Add-SFInitiatorToVolumeAccessGroup -Initiators $hba.iscsiname -VolumeAccessGroupID $vag.VolumeAccessGroupID

<#
#find and add vm's and templates for clone ops
$dss = Get-Datastore -Server $vcenter
foreach($ds in $dss) {
   # Set up Search for .VMX Files in Datastore
   $dds = Get-Datastore -Name $ds | %{Get-View $_.Id}
   $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
   $searchSpec.matchpattern = "*.vmx" -or "*vmtx"
   $dsBrowser = Get-View $dds.browser
   $datastorePath = "[" + $dds.Summary.Name + "]"
 
   # Find all .VMX file paths in Datastore, filtering out ones with .snapshot (Useful for NetApp NFS)
   $searchResult = $dsBrowser.SearchDatastoreSubFolders($datastorePath, $searchSpec) | where {$_.FolderPath -notmatch ".snapshot"} | %{$_.FolderPath + ($_.File | select Path).Path}
 
   #Register all .vmx Files as VMs on the datastore
   foreach($vmx in $searchResult) {
      New-VM -VMFilePath $vmx -VMHost $esxhost -Location $location
   }
}
#>

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End vSphere Setup ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 

	
