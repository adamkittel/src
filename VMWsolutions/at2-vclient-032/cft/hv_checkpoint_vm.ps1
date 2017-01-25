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

    $doneArray = @()
    foreach ($vm in $vms)
    {
        SfLog-Info "Creating a Checkpoint for $($vm.Name)"
        $done = ""
        $checkpoint = New-SCVMCheckpoint -VM $vm -RunAsynchronously -JobVariable "done"
        $doneArray += $done      
    }


    #loop over all the async jobs
    #hacky
    $finished_count = 0
    $i = 0
    while ($finished_count -ne $doneArray.Length -and $i -lt $doneArray.Length){
        #if we've marked the job as done then skip it
        if($doneArray[$i] -ne "Done"){
            #if the job is completed then mark it as done and tell the user
            if($doneArray[$i].Status -eq "Completed"){
                sflog-info "Checkpoint created $($doneArray[$i].ResultName)"
                $doneArray[$i] = "Done"
                $finished_count += 1
           }
        }
        $i++
        if($i -eq $doneArray.Length){
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

