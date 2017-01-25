Param(
    $MgmtServer = "cft-scvmm.cft.solidfire.net",
    $ClusterName = "cft-mscs8.cft.solidfire.net",
    $VMName = "",
    $VMRegex = "",
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

    if ($Csv -or $Bash)
    {
        Silence-SFLog
    }

    $username = "CFT\ryan.schubert"
    $password = convertto-securestring -String "solidfire" -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
    sflog-info "Connecting to $MgmtServer"
    $vmm = Get-SCVMMServer -ComputerName $MgmtServer -Credential $cred


    #if a regex is given then get all the VMs and match the names with the regex
    if($VMRegex.Length -gt 0){
        $vms = Get-SCVirtualMachine -VMMServer $vmm | Where {$_.Name -match $VMRegex}
    }
    if($VMName.Length -gt 0){
        $vms = Get-SCVirtualMachine -VMMServer $vmm | Where {$_.Name -eq $VMName}

    }

    $failed_count = 0
    foreach ($vm in $vms)
    {
        SfLog-Info "Getting checkpoints for $($vm.Name)"    
        $checkpoints = Get-SCVMCheckpoint -VM $vm
        if($checkpoints.Length -eq 0){
            SfLog-Info "The VM $($vm.Name) does not have any checkpoints"
        }
        foreach($check in $checkpoints){
            SfLog-Info "Removing Checkpoint: $($check.Name)"
            $job = ""
            Remove-SCVMCheckpoint -VMCheckpoint $check -JobVariable "job" | Out-Null
            SfLog-Info "Checkpoint $($check.Name) Status: $($job.Status)"
            if($job.Status -ne "Completed"){
                $failed_count++
            }

        }
    }
    if($failed_count -gt 0){
        SfLog-Error "Not all checkpoints could be removed"
        exit 1
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

