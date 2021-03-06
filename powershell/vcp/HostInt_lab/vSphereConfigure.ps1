param(
	[Parameter(Mandatory=$true)]
	[string]$vcenter,
	[String]$vcadmin='administrator@solidfire.eng',
	[String]$vcpass='solidF!r3',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$dsname = 'HostIntInfra'
)


.\Initialize-PowerCLIEnvironment.ps1
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

## set root folder, datacenter and cluster names
[string]$location = Get-Folder -NoRecursion -Server $vcenter
[string]$dc = 'SFdatacenter'
[string]$cl = 'SFcluster'

## create datacenter. ignore error if exists. 
if(Get-Datacenter -Server $vcenter -Name $dc -ErrorAction SilentlyContinue) {
	Write-Output "Already exists: " $dc
	} else {	
	Write-Output "*Create Datacenter"
	New-Datacenter -Name $dc -Location $location  -Server $vcenter 
}

## create cluster. do not enable ha or drs. ignore error if exists
if(Get-Cluster -Server $vcenter -Name $cl -ErrorAction SilentlyContinue) {
	Write-Output "Already exists" $cl
	} else {	
	Write-Output "*Create Cluster" 
	New-Cluster -Location $dc -Name $cl  -Server $vcenter
}

## add esxi host. if in maint mode, set to connected
if(Get-VMHost -Server $vcenter -Name $esxhost -ErrorAction SilentlyContinue) {
	Write-Output "Already exists" $esxhost
	} else {	
	Write-Output "*Add esxi host" 
	Add-VMHost -Force -Location (Get-Cluster -Server $vcenter -Name $cl) -Server $vcenter -Name $esxhost -Password $esxpass -User $esxadmin
	Set-VMHost -Server $vcenter -VMHost $esxhost -State Connected
}

Disconnect-VIServer -Confirm:$false
