param(
	[string]$sfadmin='admin',
	[string]$sfpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$mvip = '172.26.64.140',
	[Parameter(Mandatory=$true)]
	[string]$vol
)

# init powercli and SF powershell environments
.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname -note $vol

Start-Transcript -Append -Force -NoClobber -Path $transcript

$min = 0
while ($true)
{
	$volinfo = Get-SFVolume -VolumeName $vol
	if($min -ne $volinfo.Qos.MinIOPS) {
		$min = $volinfo.Qos.MinIOPS
		$max = $volinfo.QoS.MaxIOPS
		$burst = $volinfo.QoS.BurstIOPS
		[string]$timestamp = Get-Date -Format "dd-MMM-yyyy-hh:mm:ss"
		[string]$msg = $timestamp + + ' ' + $vol + ': MinIOPS: ' + $min + ' MaxIOPS: ' +  $max + ' BurstIOPS: ' + $burst
		Write-Output $msg  | Tee-Object -Append -FilePath $watchlog
	}
sleep 30
}