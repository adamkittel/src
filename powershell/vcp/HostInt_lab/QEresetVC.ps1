param (
    [String]$mvip,
    [String]$sfadmin='admin',
    [String]$sfpass='admin',
    [String]$vcenter='172.24.90.179',
    [String]$vcadmin='admin',
    [String]$vcpass='solidfire',
    [string]$fdva='172.24.90.181'
    [string]$fdvaadm='solidfire'
    [string]$fdvapass='solidfire'
)

.\Initialize-PowerCLIEnvironment.ps1
Connect-VIServer -Server $vcenter -User $vcadmin -Password $vcpass -Force -ErrorAction Stop -SaveCredentials

