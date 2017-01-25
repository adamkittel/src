param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin'
)

##########################
#
#include file for re-usable functions
#
##########################

function logSetup ([string]$basename){
	[string]$rundate = Get-Date -Format "dd-MMM-yyyy"
	
	if(!(Test-Path -Path c:\SQD\logs\$rundate)) {
		New-Item -ItemType directory -Path c:\SQD\logs\$rundate
	}
	
	[string]$globalstatfile = "c:\SQD\logs\$rundate\$basename.stat.log"
	[string]$global:checkfile = "c:\SQD\logs\$rundate\$basename.checklist.log"
	[string]$global:errwarn = "c:\SQD\logs\$rundate\$basename.errwarn.log"
	[string]$global:stdErrLog = "c:\SQD\logs\$rundate\$basename.errwarn.log"
	Start-Transcript -Append -Force -NoClobber -Path c:\SQD\logs\$rundate\$basename.trasnscript.log
	
	return $statfile,$checkfile,$errwarn
}

