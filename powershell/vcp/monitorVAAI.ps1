param(
	[string]$sfadmin='admin',
	[string]$sfpass='admin',
	[Parameter(Mandatory=$true)]
	[string]$mvip,
	[Parameter(Mandatory=$true)]
	[string]$vol
)

# init powercli and SF powershell environments
.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop

#[string]$scriptname = $myinvocation.MyCommand.Name
#. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname -note $vol

Start-Transcript -Append -Force -NoClobber -Path $transcript

$min = 0
while ($true)
{
	$volinfo = Get-SFVolumeStat (Get-SFVolume -VolumeName $vol).volumeid
	$volinfo.ActualIOPS
    $volinfo.ReadBytes
    $volinfo.ReadLatencyUSec
    $volinfo.ReadOperations
    $volinfo.VolumeUtilization
    $volinfo.WriteBytes
    $volinfo.WriteLatencyUSec
    $volinfo.WriteOps
    $volinfo.ZeroBlocks
}

