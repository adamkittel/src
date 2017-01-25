param(
	[Parameter(Mandatory=$true)]
	[String]$vcenter,
	[String]$vcadmin='admin',
	[Parameter(Mandatory=$true)]
	[String]$vcpass,
	[Parameter(Mandatory=$true)]
	[string]$newfdva,
	#[Parameter(Mandatory=$true)]
    [string]$note="NewFDVA"
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

$newurl = ("https://" + $newfdva + ":8443/solidfire/solidfire-vcp-plugin.zip")

$em = Get-View ExtensionManager
#$em.ExtensionList | Format-Table -Property Key

$sf = $em.FindExtension("com.solidfire")
Write-Output ("Current FDVA: " + $sf.server.url)

Write-Output ("Updating extension with new value: " + $newfdva)
$sf.server[0].url = $newurl
$sf.Client[0].url = $newurl

$em.UpdateExtension($sf)
Write-Output ("New FDVA: " + $sf.server.url)


<# SAMPLE
$exMgr = Get-View ExtensionManager
$vcops = $exMgr.ExtensionList | ?{$_.key -eq 'com.vmware.vcops'}
$vcops.Server[0].Url = "https://vcops-ui/vcops-vsphere/viClientConfig.xml"
$exMgr.UpdateExtension($vcops)
 #>
 

Write-Host -BackgroundColor Black -ForegroundColor Cyan "End logging to" `n $statfile `n $errwarn 
[string]$footer = "`n`n## " + (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss") + " End " + $scriptname + " ##"
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript
Disconnect-SFCluster
Disconnect-VIServer -Confirm:$false
