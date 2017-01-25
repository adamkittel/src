Param(
    [System.String] $MgmtServer = "cft-scvmm.cft.solidfire.net",
    [System.String] $ClusterName = "cft-mscs8.cft.solidfire.net",
    [System.String] $VmName = "",
    [System.String] $VmMatch = "",
    [System.Int32]  $VmCount = 0
)
Write-Host
$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

if (-not $VmMatch -and -not $VmName)
{
    SfLog-Info "Please enter either VmName or VmMatch"
    exit 1
}

try
{
    # Make sure the CWD is the same as the location of this script file
    Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path | Set-Location
    Import-Module 'C:\Program Files\Microsoft System Center 2012 R2\Virtual Machine Manager\bin\psModules\virtualmachinemanager\virtualmachinemanager.psd1' | Out-Null
    Import-Module -DisableNameChecking .\SfCft.psm1

    $username = "CFT\ryan.schubert"
    $password = convertto-securestring -String "solidfire" -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
    sflog-info "Connecting to $MgmtServer"
    $vmm = Get-SCVMMServer -ComputerName $MgmtServer -Credential $cred
    
    if ($VmName)
    {
        SfLog-Info "Searching for VM $VmName on $MgmtServer"
        $vm = Get-SCVirtualMachine -VMMServer $vmm | where { $_.Name -eq $VmName }
        if (-not $vm)
        {
            SfLog-Error "Could not find VM named $VmName"
            exit 1
        }
        SfLog-Info "Deleting $vm"
        Remove-SCVirtualMachine -VM $vm | Out-Null
    }
    else
    {
        SfLog-Info "Searching for VMs that match '$VmMatch' on $MgmtServer"
        $vm_list = @(Get-SCVirtualMachine -VMMServer $vmm | where { $_.Name -match $VmMatch }) | Sort-Object "Name"
        if ($vm_list.Length -le 0)
        {
            SfLog-Error "No VMs matched $VmMatch"
            exit 1
        }
        $count = 0
        foreach ($vm in $vm_list)
        {
            SfLog-Info "  Deleting $vm"
            Remove-SCVirtualMachine -VM $vm | Out-Null
            $count++
            if ($VmCount -gt 0 -and $count -ge $VmCount)
            {
                break
            }
        }
    }
    exit 0
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
