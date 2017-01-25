param(
	[Parameter(Mandatory=$true)]
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='solidfire',
	$volcount
)

# add params for account name or id, vol size, volume prefix
# init powercli and SF powershell environments
#.\Initialize-PowerCLIEnvironment.ps1
#.\Initialize-SFEnvironment.ps1
Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
#Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$scriptname = $myinvocation.MyCommand.Name
. c:\solidfire\scripts\BootStorm\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname 

Start-Transcript -Append -Force -NoClobber -Path $transcript

[string]$header = Write-Output '## ' (Get-Date -Format "dd-MMM-yyyy-HH.mm.ss")' Start ' $scriptname '##'

$num = 1
1..$volcount | foreach {
	$volname = 'bnpp-' + $num
	$newvol = New-SFVolume -AccountID 1 -Enable512e:$true -GB 4000 -Name $volname
	Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID 1 -VolumeID $newvol.volumeid
	$num++
}


Write-Output '**Rescan adapter'
#Get-VMHostStorage -RescanAllHba -VMHost $esxhost

Stop-Transcript
Disconnect-SFCluster -Target $mvip
#Disconnect-VIServer -Confirm:$false -Server $vcenter