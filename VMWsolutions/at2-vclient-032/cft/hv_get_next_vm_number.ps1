Param(
    $MgmtServer = "cft-scvmm.cft.solidfire.net",
    $ClusterName = "cft-mscs8.cft.solidfire.net",
    $VMPrefix = "",
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



    SFLog-Info "Finding VMs in cluster $ClusterName that match $VMPrefix"
    $vms = Get-SCVirtualMachine -VMMServer $vmm | Where { $_.Name -match $VMPrefix }
    
    if($vms.Lenght -eq 0){
        SfLog-Error "There are no matching VMs"
        exit 1
    }

    #sort the VMs by name the highest number should be on top
    $vms = $vms | Sort-Object -Property Name -Descending
    $top = $vms[0]
    #use a regex to grab the number from the end of the name
    [regex]$regex = '0*(\d+)$'
    $number = $regex.Matches($top.Name).Value -as [int]
    $number++


    if ($Csv -or $Bash){

        $separator = ","
        if ($Bash) { $separator = " " }
        Write-Host ([System.String]::Join($separator, $number))
    }
    
    else{
        SfLog-Info "The next number is $number"
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

