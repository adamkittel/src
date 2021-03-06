param(
	
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[string]$linuxvm='ubuntuServer',
	[string]$windowsvm='Windows7',
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

logSetup("deployFullClones.ps1")

## connect. exit if fail
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# since we log the warnings and failures, suppress the red output
#$ErrorActionPreference = "SilentlyContinue"

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## Start Deploy Full Clones ##" 
$header | Tee-Object -Append -FilePath $checkfile


$num = 1
$dscs = Get-DatastoreCluster -Server $vcenter

## max vm's is 512
## deploy XX vm's per datastore cluster
foreach ($dsc in $dscs)
{
	# deploy linux clones to datastore cluster
	1..40 | foreach {
		if(Get-VM -Name Fullubuntu$num -Server $vcenter) {
			[string]$pass = Write-Output "PASS: VM already exists" Fullubuntu$volnum
			$pass | Tee-Object -Append -FilePath $checkfile 
		} else {
			New-VM -Datastore $dsc -VMHost $esxhost -Template $linuxvm -Name Fullubuntu$num -RunAsync -Server $vcenter
		}
		if(Get-VM -Name 'Fullwindows7-'$num -Server $vcenter) {
			[string]$pass = Write-Output "PASS: VM already exists" Fullwindows7$volnum
			$pass | Tee-Object -Append -FilePath $checkfile 
		} else {
			New-VM -Datastore $dsc -VMHost $esxhost -Template $windowsvm -Name Fullwindows7$num -RunAsync -Server $vcenter
		}
		$num++
		# wait for 8 clones to finish
		while(Get-Task -Server $vcenter -Status Running) 
		sleep 30
	}
}



[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss")"## End Deploy Full Clones ##" 
$footer | Tee-Object -Append -FilePath $checkfile
Stop-Transcript 