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
    if($VM_name.Length -gt 0){
        $vms = Get-SCVirtualMachine -VMMServer $vmm | Where {$_.Name -eq $VMName}

    }
    
    $asyncJobs = @()
    foreach ($vm in $vms)
    {
        $checkpoints = Get-SCVMCheckpoint -VM $vm 
        if($checkpoints.Length -gt 0){
            #get the last checkpoint in the array
            $last_checkpoint = $checkpoints[-1]
            $job = ""
            SfLog-Info "Restoring $($vm.Name) to $($last_checkpoint.Name)"
            Restore-SCVMCheckpoint -VMCheckpoint $last_checkpoint -RunAsynchronously -JobVariable "job" | Out-Null
            $asyncJobs += $job
        }   
    }
    
    #loop over all the async jobs
    #hacky
    $finished_count = 0
    $i = 0
    while ($finished_count -ne $asyncJobs.Length -and $i -lt $asyncJobs.Length){
        #if we've marked the job as done then skip it
        if($asyncJobs[$i] -ne "Done"){
            #if the job is completed then mark it as done and tell the user
            if($asyncJobs[$i].Status -eq "Completed"){
                sflog-info "Restored checkpoint $($asyncJobs[$i].ResultName)"
                $asyncJobs[$i] = "Done"
                $finished_count += 1
           }
        }
        $i++
        if($i -eq $asyncJobs.Length){
            $i = 0
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

