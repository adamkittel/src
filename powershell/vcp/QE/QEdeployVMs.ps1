param(
	#[Parameter(Mandatory=$true)]
	[String]$mvip = '192.168.139.165',
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='32bitlinux',
	[string]$windowsvm='Windows7',
	#[Parameter(Mandatory=$true)]
	[String]$vcenter = '172.24.89.120',
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$esxhost = '172.24.67.2',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
    #[Parameter(Mandatory=$true)]
    [string]$note = 'vcp',
    #[Parameter(Mandatory=$true)]
    [string]$source = 'UNMAPsrc',
    #[Parameter(Mandatory=$true)]
    [string]$dest = 'UNMAPdest',
    #[Parameter(Mandatory=$true)]
    [string]$dest2 = 'UNMAPdest2',
    #[Parameter(Mandatory=$true)]
    [string]$share = 'High',
    [Parameter(Mandatory=$true)]
    [int]$count
)

# init powercli and SF powershell environments
.\Initialize-SFEnvironment.ps1
.\Initialize-PowerCLIEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -Password $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# set scriptname and run include
[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -scriptname $scriptname -note $note
Start-Transcript -Append -Force -NoClobber -Path $transcript

# start transcript and mark script start
[string]$header = '## ' + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + ' Start ' + $scriptname + ' ##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

# import initial ubuntu template
[string]$hostip = $esxhost.split('.')[3]
[string]$ds = $hostip + "template4"
Import-VApp -Source "e:\solidfire\ova\ubuntuServer-vdb.ova" -VMHost $esxhost -Name $linuxvm -Datastore $source

while((Get-Task -Status Running) -like "Deploy OVF template") {
	sleep 3
	Write-Output "Waiting for ova to complete" | Tee-Object -Append -FilePath $statfile
}

# set vm resource shares
get-vm -Name $linuxvm|Get-VMResourceConfiguration|Set-VMResourceConfiguration -Disk (Get-HardDisk -VM $linuxvm) -DiskSharesLevel $share

# virtual machine poweron operation function
function poweronVMs($vms) {
    foreach ($vm in $vms) {
        Write-Output ((Get-Date -Format "dd-MMM-yyyy-HH.mm.ss ") + "PowerOn: " + $vm) | Tee-Object -Append -FilePath $statfile
	    Start-VM -Confirm:$false -VM $vm -RunAsync
    }
}

# virtual machine poweroff operation function
function shutdownVMs($vms) {
    foreach ($vm in $vms) {
        Write-Output ((Get-Date -Format "dd-MMM-yyyy-HH.mm.ss ") + "ShutDown: " + $vm) | Tee-Object -Append -FilePath $statfile
        Stop-VM -Confirm:$false -VM $vm -RunAsync
    }
}

# virtual machine storage migrate operation function
function moveVMs($vms,$dsc) {
    foreach ($vm in $vms) {
        Write-Output ((Get-Date -Format "dd-MMM-yyyy-HH.mm.ss ") + "Migrate: " + $vm + ' To ' + $dsc) | Tee-Object -Append -FilePath $statfile
	    Move-VM -Datastore $dsc -Confirm:$false -VM $vm 
    }
}

# virtual machine remove operation function
function purgeVMs($vms) {
    foreach ($vm in $vms) {
        Write-Output ((Get-Date -Format "dd-MMM-yyyy-HH.mm.ss ") + "Purge: " + $vm) | Tee-Object -Append -FilePath $statfile
	    Remove-VM -vm $vm -Confirm:$false -DeletePermanently -RunAsync
    }
}

# deploy VMs and power on. start with default datastore cluster
$num = 1
1..$count | foreach {
    [string]$vm = $hostip + 'VM' + $num
    Write-Output ((Get-Date -Format "dd-MMM-yyyy-HH.mm.ss ") + "Deploying: " + $vm) | Tee-Object -Append -FilePath $statfile
    New-VM -Datastore $dest -VMHost $esxhost -vm $linuxvm -Name $vm -Confirm:$false -RunAsync
    $num++
}

# wait for clones to finish
while((Get-Task -Status Running) -like "CloneVM_Task") {
	sleep 3
	Write-Output "Waiting for clones to complete" | Tee-Object -Append -FilePath $statfile
}

# get a list of tenant vm's
$vms = (Get-VM -Name ($hostip + 'VM' + '*')).Name

# VM power ops
1..10 | foreach {
	# start VMs and give them a minute to boot
	poweronVMs($vms)

	while((Get-Task -Status Running) -like "Power On virtual machine") {
		sleep 3
		Write-Output "Waiting for clones to power on" | Tee-Object -Append -FilePath $statfile
	}

	# let vdbench run (runs automgicly on start up)
	Write-Output "Allow vdbench to run for 2 minutes" | Tee-Object -Append -FilePath $statfile
	sleep 120

	#shutdown VMs and wait 1 minute
	shutdownVMs($vms)
	while((Get-Task -Status Running) -like "ShutdownGuest") {
		sleep 3
		Write-Output "Waiting for clones to shutdown" | Tee-Object -Append -FilePath $statfile
	}

    # move vms to a new datstore
    Write-Output ("Storage Migrating: " + $vm) | Tee-Object -Append -FilePath $statfile
    if(Get-VM -Datastore $dest) {
        moveVMs($vms,$dest2)
    } else {
        moveVMs($vms,$dest)
    }
	
	# power vms back on
	poweronVMs($vms)
    
    while((Get-Task -Status Running) -like "Power On virtual machine") {
		sleep 3
		Write-Output "Waiting for clones to power on" | Tee-Object -Append -FilePath $statfile
	}
	
	Write-Output "Allow vdbench to run for 2 minutes" | Tee-Object -Append -FilePath $statfile
	sleep 120
	
    # power vms back off and wait 2 minutes
    shutdownVMs($vms)
    sleep 120
}



# purge vms
purgeVMs($vms)

[string]$footer = '`n`n## ' + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + ' End ' + $scriptname + ' ##'
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
Disconnect-SFCluster -ErrorVariable red
Disconnect-VIServer -Confirm:$false
