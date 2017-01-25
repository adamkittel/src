#
# set global variables
	$mvip = '192.168.139.165'
	$svip = '10.10.8.165'
	$vcenter = '192.168.129.56'
	$esxhost = '192.168.133.115'
	
	[string]$rundate = Get-Date -Format "dd-MMM-yyyy"
	
	if(!(Test-Path -Path c:\SQD\logs\$rundate)) {
		New-Item -ItemType directory -Path c:\SQD\logs\$rundate
	}
	
	Start-Transcript -Append -Force -NoClobber -Path c:\SQD\logs\$rundate\MASTER.trasnscript.log
	
	#c:\SQD\scripts\
	
	# check cluster health
	#z:\home\src\powershell\sqd\checkClusterHealth.ps1
	
	# setup the SF cluster
	#z:\home\src\powershell\sqd\setupSFcluster.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	# setup vsphere datacenter, cluster and host
	#z:\home\src\powershell\sqd\vSphereSetup.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	# set esxi software iscsi
	#z:\home\src\powershell\sqd\swiscsiSetup.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	# create datastores and datastore clusters	
	#z:\home\src\powershell\sqd\createDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	# deploy full clones. linux and windows
	#z:\home\src\powershell\sqd\deployFullClones.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	# deploy linked clones. linux & windows
	#z:\home\src\powershell\sqd\deployLinkedClones.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	# power on by VM datastore
	#z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'StartVM'
	
	# suspend by VM datastore
	#z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'SuspendVM'
	
	# power on by VM datastore
	#z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'StartVM'
	
	# guest shutdown by VM datstore
	#z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'ShutdownVMGuest'
	
	# power on by prefix
	#z:\home\src\powershell\sqd\poweropVMbyPrefix.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -vmprefix Linkedubuntu -powerop 'StartVM'
	
	# power off by prefix
	#z:\home\src\powershell\sqd\poweropVMbyPrefix.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -vmprefix Linkedubuntu -powerop 'StopVM'
	
	# deploy to SDRS cluster
	z:\home\src\powershell\sqd\deployFullClonesToSDRS.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	Stop-Transcript 