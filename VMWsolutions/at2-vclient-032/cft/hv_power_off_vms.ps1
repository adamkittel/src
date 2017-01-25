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


    #if a regex is given then get all the VMs and match the names with the regex
    if($VMRegex.Length -gt 0){
        $vms = Get-SCVirtualMachine -VMMServer $vmm | Where {$_.Status -eq "Running"} | Where {$_.Name -match $VMRegex} | Sort-Object -Property Name
    }
    if($VMName.Length -gt 0){
        $vms = Get-SCVirtualMachine -VMMServer $vmm | Where {$_.Name -eq $VMName} | Where {$_.Status -eq "Running"} | Sort-Object -Property Name

    }
    
    $vmCount = $vms.Count
    sflog-info "There are $vmCount VMs on the cluster that will be powered off"
    foreach ($vm in $vms)
    {
        sflog-info "Powering off $vm"
        if($vm.Status -eq "PowerOff"){
            SfLog-Info "The VM: $vm is already turned off"
        }
        else{
            Stop-VM -VM $vm | Out-Null

            if($vm.Status -eq "PowerOff"){
                SfLog-Info "The VM: $vm has powered off"
            }else{
                SfLog-Error "There was an error powering off the VM: $vm the status is: $($vm.Status)"
            }
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

