param(
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire'
)

# init powercli and SF powershell environments
#.\Initialize-SFEnvironment.ps1
.\Initialize-PowerCLIEnvironment.ps1
#Connect-SFCluster -UserName $sfadmin -Password $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

# set scriptname and run include
[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -scriptname $scriptname -note $note
Start-Transcript -Append -Force -NoClobber -Path $transcript

# start transcript and mark script start
[string]$header = '## ' + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + ' Start ' + $scriptname + ' ##'
$header | Tee-Object -Append -FilePath $statfile
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to" `n $statfile `n $errwarn 


$em = Get-View ExtensionManager
$em.ExtensionList | Format-Table -Property Key
 
$em.UnregisterExtension("com.solidfire")
$em.UnregisterExtension("com.solidfire.qossioc")
 
$em.UpdateViewData()
$em.ExtensionList | ft -Property Key
 

Write-Host -BackgroundColor Black -ForegroundColor Cyan "End logging to" `n $statfile `n $errwarn 
[string]$footer = "`n`n## " + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + " End " + $scriptname + " ##"
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
#Disconnect-SFCluster
Disconnect-VIServer -Confirm:$false