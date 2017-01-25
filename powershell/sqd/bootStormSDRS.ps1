param(
	
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$maxprefix='max',
	[string]$minprefix='min',
	[string]$defprefix='def',
	[string]$rdmprefix='rdm',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost,
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

. z:\home\src\powershell\sqd\include.ps1
#. c:\SQD\scripts\include.ps1
#c:\SQD\scripts\Initialize-SFEnvironment.ps1
#c:\SQD\scripts\Initialize-PowerCLIEnvironment.ps1

logSetup("bootStormSDRS.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start SDRS boot storm ##" 
$header | Tee-Object -Append -FilePath $checkfile

#boot storm by datastore cluster
$num = 1
$dscs = Get-DatastoreCluster -Server $vcenter
foreach ($dsc in $dscs)
{
	[string]$msg = Write-Output "Power on all VM's in datastore cluster: " $dsc
	$pass | Tee-Object -Append -FilePath $checkfile		
	Get-VM -Datastore $dsc -Server $vcenter | Start-VM -Server $vcenter -RunAsync
	
	while((Get-Task -Server $vcenter -Status Running))		{
			Write-Host "Waiting for tasks to finish. Sleeping 20 seconds" 
			sleep 20
	}
	foreach ($vm in $vms) {
		$powerstate = Get-VM $vm
		if($powerstate.PowerState -eq 'PoweredOn') {
			[string]$pass = Write-Output "PASS: VM powered on: " $powerstate.name $powerstate.PowerState
			$pass | Tee-Object -Append -FilePath $checkfile		
		} else {
			[string]$err = Write-Output "FAIL: VM not powered on: " $powerstate.name $powerstate.PowerState
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $checkfile
		}
	}
}


[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End SDRS boot storm ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 