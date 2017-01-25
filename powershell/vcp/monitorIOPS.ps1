param(
	[string]$sfadmin='admin',
	[string]$sfpass='admin',
	#[Parameter(Mandatory=$true)]
	[string]$mvip = '192.168.139.165',
	[Parameter(Mandatory=$true)]
	[string]$vol,
    [Parameter(Mandatory=$true)]
    [string]$note
)

# init powercli and SF powershell environments
.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -Password $sfpass -Target $mvip -ErrorAction Stop

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -scriptname $scriptname -note $note

#Start-Transcript -Append -Force -NoClobber -Path $transcript

$volid = (Get-SFVolume -Name $vol).VolumeID
$min = 0
while ($true)
{
    $volstat = Get-SFVolumeStats -VolumeID $volid
    $timestamp = (Get-Date -Format "dd-MMM-yyyy-hh:mm:ss")
    $msg = ($timestamp + "," + $vol + "," + $volstat.ActualIOPS + "," + $volstat.ReadOps + "," + $volstat.WriteOps + "," + $volstat.ReadLatencyUSec + "," + $volstat.WriteLatencyUSec + "," + $volstat.ClientQueueDepth) 
    $msg | Tee-Object -Append -FilePath $statfile
    sleep 5
}