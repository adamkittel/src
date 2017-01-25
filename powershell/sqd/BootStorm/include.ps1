param(
[Parameter(Mandatory=$true)]
	[String]$mvip,
[Parameter(Mandatory=$true)]
	[String]$sfadmin,
[Parameter(Mandatory=$true)]
	[String]$sfpass,
[Parameter(Mandatory=$true)]	
	[string]$scriptname
)

##########################
#
#include file for re-usable functions and common variables
#
##########################
c:\Users\Administrator\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop

[string]$global:clustername = (Get-SFClusterInfo).name
[string]$global:rundate = Get-Date -Format "ddMMyyyy_hhmmss"
[string]$global:path = 'c:\solidfire\logs\' + $scriptname + '\' + $clustername + '\'
[string]$global:logpath = $path + '\' + $rundate 

if(!(Test-Path -Path $logpath)) {
	New-Item -ItemType directory -Path $logpath
}

[string]$global:statfile = $logpath + '\' + 'stat.log'
[string]$global:errwarn = $logpath + '\' + 'errwarn.log'
[string]$global:stdErrLog = $logpath + '\' + 'errwarn.log'
[string]$global:transcript = $logpath + '\' + 'transcript'

