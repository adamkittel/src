param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='solidfire',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)
# add params for vol prefix, datastore prefix, 
# init powercli and SF powershell environments
#.\Initialize-PowerCLIEnvironment.ps1
#.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop 
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

<#
[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript
#>

Write-Output '**Get-SFAccountEfficiency**'
Get-SFAccountEfficiency -AccountID 1

Write-Output '**Get-SFClusterCapacity**'
Get-SFClusterCapacity 

Write-Output '**Get-SFClusterFullThreshold**'
Get-SFClusterFullThreshold

Write-Output '**Get-SFClusterStat**' 
Get-SFClusterStat

Write-output '**Get-DatastoreCluster**'
Get-DatastoreCluster

Write-Output '**Get-Datastore**'
$dss = Get-Datastore
foreach ($ds in $dss) {
[string]$dsinfo = $ds.Name + ': ' + 'FreeSpaceGB: ' + $ds.FreeSpaceGB
Write-Output $dsinfo
}

Disconnect-SFCluster -Target $mvip
Disconnect-VIServer -Confirm:$false -Server $vcenter
