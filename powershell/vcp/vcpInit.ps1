﻿# set global variables
	$mvip = '192.168.139.165'
	$svip = '10.10.8.165'
	$vcenter = '192.168.129.90'
	$esxhost = '192.168.133.115'
	$vcadmin = 'admin'
	$vcpass = 'solidfire'
	$sfadmin = 'admin'
	$sfpass = 'admin'
	
		# init powercli and SF powershell environments
	c:\SQD\scripts\Initialize-SFEnvironment.ps1
	c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1
	
	## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

