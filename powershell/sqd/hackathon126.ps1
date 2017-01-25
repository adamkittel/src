#
# set global variables
	[string]$mvip = '172.26.64.156'
	[string]$svip = '10.26.64.156'
	[string]$vcenter = '192.168.129.144'
	[string]$esxhost = '192.168.133.126'
	[string]$vcadmin = 'admin'
	[string]$vcpass = 'solidfire'
	[string]$sfadmin = 'admin'
	[string]$sfpass = 'admin'
	[string]$vmnic1 = 'vmnic0'
	[string]$vmnic2 = 'vmnic1'
	[string]$windowsvm = 'Windows7'
	[string]$rundate = Get-Date -Format "dd-MMM-yyyy-hhmmss"
	
	c:\SQD\scripts\Initialize-SFEnvironment.ps1
	## connect. exit if fail
	Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
	$clustername = ((Get-SFClusterInfo).name.split('-')[0])
	
	if(!(Test-Path -Path c:\SQD\logs\$rundate)) {
		New-Item -ItemType directory -Path c:\SQD\logs\$rundate
	}
	# init powercli and SF powershell environments
	c:\SQD\scripts\Initialize-SFEnvironment.ps1
	c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1
	
	Start-Transcript -Append -Force -NoClobber -Path c:\SQD\logs\$clustername\$rundate\MASTER.trasnscript.log
	
	#c:\SQD\scripts\
	
	# check cluster health
	z:\home\src\powershell\sqd\checkClusterHealth.ps1 -mvip $mvip -svip $svip -sfadmin $sfadmin -sfpass $sfpass
	
	# setup the SF cluster
	#z:\home\src\powershell\sqd\setupSFcluster.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass  
	z:\home\src\powershell\sqd\setupSFcluster-switch.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass  
	
	# setup vsphere datacenter, cluster and host
	z:\home\src\powershell\sqd\vSphereSetup.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass  
	
	# set esxi software iscsi
	z:\home\src\powershell\sqd\swiscsiSetup.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -vmnic1 $vmnic1 -vmnic2 $vmnic2  
	
	# create datastores and datastore clusters	
	z:\home\src\powershell\sqd\createDatastoreClusters.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass  
	
	#deploy full clones to datastore clusters
	z:\home\src\powershell\sqd\deployFullClonesToSDRS.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass  -windowsvm $windowsvm 
	
	#deploy linked clones to datastore clusters
	z:\home\src\powershell\sqd\deployLinkedClonesToSDRS.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass 
	
	# deploy full clones. linux and windows
	##z:\home\src\powershell\sqd\deployFullClones.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass  -windowsvm $windowsvm -dsname #full clone ds
	
	# deploy linked clones. linux & windows
	##z:\home\src\powershell\sqd\deployLinkedClones.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass -windowsvm $windowsvm -dsname #linked clone ds
	
	# power on by VM datastore cluster
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*DSCdefault' -powerop 'StartVM' -sfpass $sfpass 
	
	# suspend by VM datastore
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*DSCdefault' -powerop 'SuspendVM' -sfpass $sfpass
	
	# power on by VM datastore
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*DSCdefault' -powerop 'StartVM' -sfpass $sfpass
	
	# guest shutdown by VM datstore
	z:\home\src\powershell\sqd\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*DSCdefault' -powerop 'ShutdownVMGuest' -sfpass $sfpass 
	
	# power on by prefix
	z:\home\src\powershell\sqd\poweropVMbyPrefix.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix '*Linkedubuntu' -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm
	
	# power off by prefix
	z:\home\src\powershell\sqd\poweropVMbyPrefix.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix '*Linkedubuntu' -powerop 'StopVM' -sfadmin $sfadmin -sfpass $sfpass -windowsvm $windowsvm
	
	# add rdm's to full clone VM's
	z:\home\src\powershell\sqd\addRDMdisk.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass 
	
	# power on vm's
	z:\home\src\powershell\sqd\poweropAllVM.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm

	# guest shutdown vm's
	z:\home\src\powershell\sqd\poweropAllVM.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerop 'StopVM' -sfpass $sfpass 
	
	# change psp to RR
	z:\home\src\powershell\sqd\changePSP.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -psp 'RoundRobin'
	
	# power on vm's
	z:\home\src\powershell\sqd\poweropAllVM.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm

	# guest shutdown vm's
	z:\home\src\powershell\sqd\poweropAllVM.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerop 'StopVM' -sfpass $sfpass 
	
	# change psp to MRU	
	z:\home\src\powershell\sqd\changePSP.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -psp 'MostRecentlyUsed'
	
	# power on vm's
	z:\home\src\powershell\sqd\poweropAllVM.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm

	# guest shutdown vm's
	z:\home\src\powershell\sqd\poweropAllVM.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerop 'StopVM' -sfpass $sfpass 
	
	# snapshot Full clones powered off
	z:\home\src\powershell\sqd\takeVMsnapshots.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerstate PoweredOff
	
	# power on vm's
	z:\home\src\powershell\sqd\poweropAllVM.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm

	# snapshot Full clones powered on
	z:\home\src\powershell\sqd\takeVMsnapshots.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerstate PoweredOn
	
	
	
	Stop-Transcript 
