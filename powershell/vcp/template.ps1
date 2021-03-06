param(
	#[Parameter(Mandatory=$true)]
	[String]$mvip = '172.26.64.140',
	[String]$sfadmin='admin',
	[String]$sfpass='solidfire',
	[string]$linuxvm='ubuntuServer-vdb',
	[string]$windowsvm='Windows7',
	#[Parameter(Mandatory=$true)]
	[String]$vcenter = '192.168.129.228',
	[String]$vcadmin='administrator@solidfire.eng',
	[String]$vcpass='solidF!r3',
	#[Parameter(Mandatory=$true)]
	[string]$esxhost = '172.26.254.176',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire',
	#[Parameter(Mandatory=$true)]
	[string]$deployvol = 'deploy-dest',
	#[Parameter(Mandatory=$true)]
	[string]$svmvol = 'svm-dest',
	[Parameter(Mandatory=$true)]
	[string]$share #Low,Normal,High
)


	.\Initialize-SFEnvironment.ps1
	.\Initialize-PowerCLIEnvironment.ps1

Connect-SFCluster -UserName $sfadmin -ClearPassword $sfpass -Target $mvip -ErrorAction Stop
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

[string]$scriptname = $myinvocation.MyCommand.Name
. .\include.ps1 -mvip $mvip -sfadmin $sfadmin -sfpass $sfpass -scriptname $scriptname

Start-Transcript -Append -Force -NoClobber -Path $transcript
Write-Host -BackgroundColor Black -ForegroundColor Cyan "Logging to"  $statfile

[string]$header = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss ")"## Start Deploy Full Clones ##" 
$header | Tee-Object -Append -FilePath $statfile

Disconnect-SFCluster 
Disconnect-VIServer -Confirm:$false

[string]$footer = Write-Output "## " (Get-Date -Format "dd-MMM-yyyy-HH:mm:ss ")"## End Deploy Full Clones ##" 
$footer | Tee-Object -Append -FilePath $statfile
Stop-Transcript 
