#
# set global variables
	[string]$mvip = '172.26.64.137'
	[string]$svip = '10.26.64.137'
	[string]$vcenter = '192.168.129.207'
	[string]$esxhost = '172.26.254.176'
	[string]$vcadmin = 'admin'
	[string]$vcpass = 'solidfire'
	[string]$sfadmin = 'admin'
	[string]$sfpass = 'solidfire'
	[string]$vmnic1 = 'vmnic0'
	[string]$vmnic2 = 'vmnic1'
	[string]$windowsvm = 'Windows7'
	[string]$rundate = Get-Date -Format "dd-MMM-yyyy"
	
	# init powercli and SF powershell environments
	.\Initialize-SFEnvironment.ps1
	.\Initialize-PowerCLIEnvironment.ps1

	Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
	Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

	#Start-Transcript -Append -Force -NoClobber -Path $logpath\MASTER.trasnscript.log
	
	# check cluster health
	.\checkClusterHealth.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass
	
	# setup the SF cluster
	#.\setupSFcluster-switch.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost
	
	# setup vsphere datacenter, cluster and host
	#.\vSphereSetup.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass  
	
	# set esxi software iscsi
	#.\swiscsiSetup.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -vmnic1 $vmnic1 -vmnic2 $vmnic2  
	
	# create datastores and datastore clusters	
	#.\createDatastoreClusters.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass  
	
	# check cluster health
	.\checkClusterHealth.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass
	
	#deploy full clones to datastore clusters VAAI
	.\deployFullClonesToSDRS.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass
	
	# check cluster health
	.\checkClusterHealth.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass
	
	#deploy linked clones to datastore clusters
	#.\deployLinkedClonesToSDRS.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfpass $sfpass 
	
	# deploy full clones. linux and windows non-VAAI
	#.\deployFullClones.ps1 -mvip $mvip -vcenter $vcenter -esxhost $esxhost -sfpass $sfpass  -windowsvm $windowsvm -dsname #full clone ds
	
	# power on by VM datastore cluster
	.\poweropVMbyDatastore.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*default' -powerop 'StartVM' -sfpass $sfpass 
	
	# suspend by VM datastore
	.\poweropVMbyDatastore.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*default' -powerop 'SuspendVM' -sfpass $sfpass
	
	# power on by VM datastore
	.\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*DSCdefault' -powerop 'StartVM' -sfpass $sfpass
	
	# guest shutdown by VM datstore
	.\poweropVMbyDatastore.ps1 -mvip $mvip -svip $svip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -datastore '*DSCdefault' -powerop 'StopVM' -sfpass $sfpass 
	
	# power on by prefix
	.\poweropVMbyPrefix.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix '*Linkedubuntu' -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm
	
	# power off by prefix
	.\poweropVMbyPrefix.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix '*Linkedubuntu' -powerop 'StopVM' -sfadmin $sfadmin -sfpass $sfpass -windowsvm $windowsvm
	
	# add rdm's to full clone VM's
	.\addRDMdisk.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -persistence NonPersistent
	
	# power on vm's
	.\poweropAllVM.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm

	# guest shutdown vm's
	.\poweropAllVM.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerop 'StopVM' -sfpass $sfpass 
	
	# change psp to RR
	.\changePSP.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -psp 'RoundRobin'
	
	# power on vm's
	.\poweropAllVM.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm

	# poweroff vm's
	.\poweropAllVM.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerop 'StopVM' -sfpass $sfpass 
	
	# change psp to MRU	
	.\changePSP.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -psp 'MostRecentlyUsed'
	
	# add flat vmdk
	
	# power on vm's
	.\poweropAllVM.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass

	# guest shutdown vm's
	.\poweropAllVM.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerop 'StopVM' -sfpass $sfpass 
	
	# change psp to RR
	.\changePSP.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -sfadmin $sfadmin -sfpass $sfpass -psp 'RoundRobin'
		
	# snapshot Full clones powered off
	.\takeVMsnapshots.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerstate PoweredOff
	
	# power on vm's
	.\poweropAllVM.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -vmprefix -powerop 'StartVM' -sfadmin $sfadmin -sfpass $sfpass  -windowsvm $windowsvm

	# snapshot Full clones powered on
	.\takeVMsnapshots.ps1 -mvip $mvip -vcenter $vcenter -vcadmin $vcadmin -vcpass $vcpass -esxhost $esxhost -powerstate PoweredOn
	
	
	
	Stop-Transcript 
