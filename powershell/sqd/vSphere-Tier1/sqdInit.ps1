param(
	[string]$mvip = '192.168.139.165',
	[string]$svip = '10.10.8.165',
	[string]$vcenter = '192.168.129.110',
	[string]$esxhost = '192.168.139.115',
	[string]$vcadmin = 'admin',
	[string]$vcpass = 'solidfire',
	[string]$sfadmin = 'admin',
	[string]$sfpass = 'admin'
)

c:\SQD\scripts\Initialize-SFEnvironment.ps1
c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer  -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials
