Param(
    $MgmtServer = "cft-scvmm.cft.solidfire.net",
    $ClusterName = "cft-mscs8.cft.solidfire.net",
    [Switch] $Csv,
    [Switch] $Bash
)
Write-Host
$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

try
{
    # Make sure the CWD is the same as the location of this script file
    Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path | Set-Location
    Import-Module 'C:\Program Files\Microsoft System Center 2012 R2\Virtual Machine Manager\bin\psModules\virtualmachinemanager\virtualmachinemanager.psd1' | Out-Null
    Import-Module -DisableNameChecking .\SfCft.psm1
    Import-Module -DisableNameChecking .\sfdefaults.psm1

    if ($Csv -or $Bash)
    {
        Silence-SFLog
    }

    $username = "CFT\ryan.schubert"
    $password = convertto-securestring -String "solidfire" -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
    sflog-info "Connecting to $MgmtServer"
    $vmm = Get-SCVMMServer -ComputerName $MgmtServer -Credential $cred

    SFLog-Info "Finding nodes in cluster $ClusterName"
    $cluster = Get-SCVMHostCluster -VMMServer $vmm -Name $ClusterName
    $host_list = @()
    foreach ($vmhost in $cluster | Get-SCVMHost)
    {
        $host_list += $vmhost.FullyQualifiedDomainName
    }

    if ($Csv -or $Bash)
    {
        $separator = ","
        if ($Bash) { $separator = " " }

        Write-Host ([System.String]::Join($separator, $host_list))
    }
    else
    {
        foreach ($hostname in $host_list)
        {
            SFLog-Info ("  " + $hostname)
        }
    }
}
catch
{
    $err_message = $_.ToString() + "`n`t" + $_.ScriptStackTrace
    try { SfLog-Error $err_message }
    catch { Write-Host $err_message }
    exit 1
}
finally
{
    try { Reinstate-SfLog } catch {}
    Write-Host
}

