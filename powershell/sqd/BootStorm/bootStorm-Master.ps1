#
# set global variables
	[string]$mvip = '172.26.64.140'
	[string]$vcenter = '172.26.254.166'
	[string]$esxhost = '172.26.254.42'
	[string]$vcadmin = 'admin'
	[string]$vcpass = 'solidfire'
	[string]$sfadmin = 'admin'
	[string]$sfpass = 'solidfire'
	[string]$parentvm = 'Windows7'
	[string]$rundate = Get-Date -Format "dd-MMM-yyyy"
	
	# init powercli and SF powershell environments
	c:\Users\Administrator\Initialize-SFEnvironment.ps1
	c:\Users\Administrator\Initialize-SFEnvironment.ps1

	#Start-Transcript -Append -Force -NoClobber -Path $logpath\MASTER.trasnscript.log
	
	# check cluster health
	c:\solidfire\scripts\BootStorm\bootStorm-checkUsage.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost
<#	
	#make volumes
	#c:\solidfire\scripts\BootStorm\bootStorm-CreateVolumes.ps1 -mvip $mvip -volcount 10

	#set psp to RR
	c:\solidfire\scripts\BootStorm\bootStorm-ChangePSP.ps1 -mvip $mvip -vcenter $vcenter -esxhost '172.26.254.42'
	c:\solidfire\scripts\BootStorm\bootStorm-ChangePSP.ps1 -mvip $mvip -vcenter $vcenter -esxhost '172.26.254.43'
	c:\solidfire\scripts\BootStorm\bootStorm-ChangePSP.ps1 -mvip $mvip -vcenter $vcenter -esxhost '172.26.254.44'
	
	
	#make datastores
	c:\solidfire\scripts\BootStorm\bootStorm-CreateDatastores.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost
#>	
	#deploy clones
	c:\solidfire\scripts\BootStorm\bootStorm-deployClones.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost
	
	#power on
	c:\solidfire\scripts\BootStorm\bootStorm-powerOp.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost
	