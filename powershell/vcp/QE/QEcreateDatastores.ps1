param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[Parameter(Mandatory=$true)]
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
    [string]$note = 'TestRun'
)

# init powercli and SF powershell environments
.\Initialize-SFEnvironment.ps1
.\Initialize-PowerCLIEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -Password $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# set scriptname and run include
[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -scriptname $scriptname -note $note

# start transcript and mark script start
Start-Transcript -Append -Force -NoClobber -Path $transcript
[string]$header = '## ' + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + ' Start ' + $scriptname + ' ##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 

# rescan esxi adpaters
Write-Output "Rescan adapters" | Tee-Object -Append -FilePath $statfile
#Get-VMHostStorage -vmHost $esxhost -RescanAllHba 

# set variables
[string]$hostip = $esxhost.split('.')[3]
[string]$account = $hostip + 'account'
[string]$accountid = (Get-SFAccount -UserName $account).AccountID
[string]$dscdef = $hostip + 'DSCdefault'
[string]$dscmin = $hostip + 'DSCmin'
[string]$dscmax = $hostip + 'DSCmax'
[string]$location = "HostInt"
[string]$datastoretypes = 'min','max','def'

<#
# create datastore clusters
foreach ($datastoretype in $datastoretypes) {
	switch ($datastoretype) {
        "min" {
            Write-Output ("Create datastore cluster " + $dscmin) | Tee-Object -Append -FilePath $statfile 
	        New-DatastoreCluster -Location $location -Name $dscmin -Confirm:$false
	        Set-DatastoreCluster -DatastoreCluster $dscmin -IOLoadBalanceEnabled:$true -SdrsAutomationLevel FullyAutomated 
	    }
        "max" {
            Write-Output ("Create datastore cluster " + $dscmax) | Tee-Object -Append -FilePath $statfile 
	        New-DatastoreCluster -Location $location -Name $dscmax -Confirm:$false
	        Set-DatastoreCluster -DatastoreCluster $dscmax -IOLoadBalanceEnabled:$true -SdrsAutomationLevel FullyAutomated 
	    }
        "def" {
            Write-Output ("Create datastore cluster " + $dscdef) | Tee-Object -Append -FilePath $statfile 
	        New-DatastoreCluster -Location $location -Name $dscdef -Confirm:$false 
	        Set-DatastoreCluster -DatastoreCluster $dscdef -IOLoadBalanceEnabled:$true -SdrsAutomationLevel FullyAutomated 
	    }
    }
}
#>

# create datastores and move into datastore clusters
Write-Output "Create datastores with SIOC enabled" | Tee-Object -Append -FilePath $statfile
$vols = Get-SFVolume -Accountid $accountid

foreach ($vol in $vols) {
	$volpath = 'naa.' + $vol.ScsiNAADeviceID
	New-Datastore -Vmfs -Name $vol.Name -Path $volpath -VMHost $esxhost -Confirm:$false 
	Set-Datastore -StorageIOControlEnabled $true -Datastore $vol.Name -Confirm:$false
	
    if ($vol -like '*minQOS*') {
            Write-Output ("Move datastore " + $vol.Name + " to datastore cluster " + $dscmin) | Tee-Object -Append -FilePath $statfile 
            Move-Datastore -Destination $dscmin -Datastore $vol.Name -Confirm:$false 
    }
    if ($vol -like '*maxQOS*') {
            Write-Output ("Move datastore " + $vol.Name + " to datastore cluster " + $dscmax) | Tee-Object -Append -FilePath $statfile 
            Move-Datastore -Destination $dscmax -Datastore $vol.Name -Confirm:$false 
    }
    if ($vol -like '*defaultQOS*') {
            Write-Output ("Move datastore " + $vol.Name + " to datastore cluster " + $dscdef) | Tee-Object -Append -FilePath $statfile 
            Move-Datastore -Destination $dscdef -Datastore $vol.Name -Confirm:$false 
    }
}

 
[string]$footer = "## " + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + " End " + $scriptname + " ##"
$footer | Tee-Object -Append -FilePath $statfile
Disconnect-SFCluster 
Disconnect-VIServer -Force -Confirm:$false -Server *
Stop-Transcript 
