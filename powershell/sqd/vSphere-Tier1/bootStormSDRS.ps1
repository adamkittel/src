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
	[string]$esxpass='solidfire'
)

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start SDRS boot storm ##" 
$header | Tee-Object -Append -FilePath $statfile

#boot storm by datastore cluster
$num = 1
$dscs = Get-DatastoreCluster 
foreach ($dsc in $dscs)
{
	[string]$msg = Write-Output "Power on all VM's in datastore cluster: " $dsc
	$pass | Tee-Object -Append -FilePath $statfile		
	Get-VM -Datastore $dsc  | Start-VM  -RunAsync
	
	while((Get-Task  -Status Running))		{
			Write-Host "Waiting for tasks to finish. Sleeping 20 seconds" 
			sleep 20
	}
	foreach ($vm in $vms) {
		$powerstate = Get-VM $vm
		if($powerstate.PowerState -eq 'PoweredOn') {
			[string]$pass = Write-Output "PASS: VM powered on: " $powerstate.name $powerstate.PowerState
			$pass | Tee-Object -Append -FilePath $statfile		
		} else {
			[string]$err = Write-Output "FAIL: VM not powered on: " $powerstate.name $powerstate.PowerState
			$err | Tee-Object -Append -FilePath $errwarn 
			$err | Out-File -Append -FilePath $statfile
		}
	}
}


[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End SDRS boot storm ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
