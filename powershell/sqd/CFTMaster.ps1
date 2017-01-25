#
# set global variables
	$mvip = '172.26.64.137'
	$svip = '10.26.64.137'
	$vcenter = '172.26.254.246'
	$esxhost = '172.26.254.176'
	$vcadmin = 'admin'
	$vcpass = 'solidfire'
	$sfadmin = 'admin'
	$sfpass = 'admin'
	$vmnic1 = 'vmnic0'
	$vmnic2 = 'vmnic1'
	[string]$rundate = Get-Date -Format "dd-MMM-yyyy"
	
	if(!(Test-Path -Path c:\SQD\logs\$rundate)) {
		New-Item -ItemType directory -Path c:\SQD\logs\$rundate
	}
	
	Start-Transcript -Append -Force -NoClobber -Path c:\SQD\logs\$rundate\MASTER.trasnscript.log
	
	#c:\SQD\scripts\
	
	# check cluster health
	#z:\home\src\powershell\sqd\checkClusterHealth.ps1 -mvip $mvip -svip $svip -sfadmin $sfadmin -sfpass $sfpass
	
	# setup the SF cluster
	#z:\home\src\powershell\sqd\setupSFcluster.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# setup vsphere datacenter, cluster and host
	#z:\home\src\powershell\sqd\vSphereSetup.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# set esxi software iscsi
	z:\home\src\powershell\sqd\swiscsiSetup.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass -vmnic1 $vmnic1 -vmnic2 $vmnic2
	
	# create datastores and datastore clusters	
	z:\home\src\powershell\sqd\createDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# deploy full clones. linux and windows
	z:\home\src\powershell\sqd\deployFullClones.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# deploy linked clones. linux & windows
	z:\home\src\powershell\sqd\deployLinkedClones.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# power on by VM datastore
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'StartVM' -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# suspend by VM datastore
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'SuspendVM' -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# power on by VM datastore
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'StartVM' -sfpass $sfpass -vcadmin $vcadmin -vcpass $vcpass
	
	# guest shutdown by VM datstore
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -datastore linkedClones-31 -powerop 'ShutdownVMGuest' -vcadmin $vcadmin -vcpass $vcpass
	
	# power on by prefix
	z:\home\src\powershell\sqd\poweropVMbyPrefix.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -vmprefix Linkedubuntu -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass
	
	# power off by prefix
	z:\home\src\powershell\sqd\poweropVMbyPrefix.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -vmprefix Linkedubuntu -powerop 'StopVM' -sfadmin $sfadmin -sfpass $sfpass
	
	# deploy to SDRS cluster
	z:\home\src\powershell\sqd\deployFullClonesToSDRS.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost
	
	Stop-Transcript 
