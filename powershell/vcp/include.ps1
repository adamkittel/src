param(
[Parameter(Mandatory=$true)]
	[String]$mvip,
[Parameter(Mandatory=$true)]
	[String]$sfadmin,
[Parameter(Mandatory=$true)]
	[String]$sfpass,
[Parameter(Mandatory=$true)]
	[String]$note,
[Parameter(Mandatory=$true)]	
	[string]$scriptname
)

##########################
#
#include file for re-usable functions and common variables
#
##########################
# call this after connecting
#.\Initialize-SFEnvironment.ps1
#Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop

[string]$global:clustername = (Get-SFClusterInfo).name
# [string]$clustername.name.split('-')[0,1] -replace ' '.'-'
[string]$global:rundate = Get-Date -Format "dd-MMM-yyyy-hhmmss"
[string]$global:path = 'z:\test\' + $scriptname + '\' + $clustername + '\' + $note + '\'
[string]$global:logpath = $path + $rundate + '\'

if(!(Test-Path -Path $logpath)) {
	New-Item -ItemType directory -Path $logpath
}

[string]$global:statfile = $logpath + 'deploy.log'
[string]$global:watchlog = $logpath + 'watch.log'
[string]$global:errwarn = $logpath + 'errwarn.log'
[string]$global:stdErrLog = $logpath + 'errwarn.log'
[string]$global:transcript = $logpath + 'transcript'

