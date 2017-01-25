Param(
    $ClusterName = "cft-mscs8.cft.solidfire.net"
)
Write-Host
$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

try
{
    # Make sure the CWD is the same as the location of this script file
    Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path | Set-Location
    Import-Module FailoverClusters
    Import-Module -DisableNameChecking .\SfCft.psm1

    # Add all available disks as cluster resources
    SfLog-Info "Adding available disks to the cluster"
    foreach ($disk in Get-ClusterAvailableDisk -Cluster $ClusterName)
    {
        SfLog-Info ("  Adding " + $disk.Name + " to the cluster")
        Add-ClusterDisk $disk  | Out-Null
        SfLog-Info ("  Waiting for " + $disk.Name + " to come online")
        while ($true)
        {
            if ((Get-ClusterResource -Cluster $ClusterName -Name $disk.Name).State -eq "Online")
            {
                break
            }
            Start-Sleep 5
        }
    }

    # Rename cluster resources to match disk volume labels (which should also be the SF volume name)
    SfLog-Info "Renaming disk resources to match volume names"
    foreach ($cluster_disk in Get-ClusterResource -Cluster cft-mscs8 | Where-Object {$_.OwnerGroup -match "Available Storage"})
    {
        # Get the disk signature
        $disk_sig = ($cluster_disk | Get-ClusterParameter -Name DiskSignature).Value
        # Convert signature from hex (0xABCD1234) to decimal (2882343476) - the cluster commands use hex but the WMI objects use dec
        $disk_sig = [Convert]::ToUInt32($disk_sig, 16)
    
        # Get the volume label
        $disk_wmi = Get-WmiObject -Query "SELECT * FROM MSCluster_Disk WHERE Signature=$disk_sig" -Namespace root/MSCluster -ComputerName $ClusterName -Authentication PacketPrivacy
        $partition_wmi =  Get-WmiObject -Query "ASSOCIATORS OF {$disk_wmi} WHERE ResultClass=MSCluster_DiskPartition" -Namespace root/MSCluster -ComputerName $ClusterName -Authentication PacketPrivacy

        # Set the name of the clsuter resource to be the volume label
        if ($cluster_disk.Name -ne $partition_wmi.VolumeLabel)
        {
            SfLog-Info ("  Renaming " + $cluster_disk.Name + " to " + $partition_wmi.VolumeLabel)
            $cluster_disk.Name = $partition_wmi.VolumeLabel
        }
    }

    # Create CSV for each new disk
    SfLog-Info "Adding available disk resources to Cluster Shared Volumes"
    foreach ($disk in Get-ClusterResource -Cluster cft-mscs8 | Where-Object {$_.OwnerGroup -match "Available Storage"})
    {
        $retry = 0
        while ($retry -lt 3)
        {
            $error1 = $false
            SfLog-Info ("  Adding " + $disk.Name + " as a CSV")
            $csv = Add-ClusterSharedVolume -Cluster $ClusterName -Name $disk.Name
            $csv_path = $csv.SharedVolumeInfo.FriendlyVolumeName
            if ($csv_path -eq "C:\ClusterStorage\")
            {
                SfLog-Warn ("  " + $disk.Name + " incorrectly mounted at C:\ClusterStorage\ - attempting to fix")
                Remove-ClusterSharedVolume -Cluster $ClusterName -Name $disk.Name | Out-Null
                $retry++
                $error1 = $true
                Start-Sleep 10
                continue
            }
            break;
        }
        if ($error1)
        {
            SfLog-Error ("Could not correctly mount " + $disk.Name)
            continue
        }

        SfLog-Info ("  Renaming " + $disk.Name + " mount point")
        # Rename the mount folder to match the volume name
        # Use powershell remoting to execute the command on the remote system
        Invoke-Command -ComputerName $ClusterName -ScriptBlock { Rename-Item -Path $args[0].SharedVolumeInfo.FriendlyVolumeName -NewName ("C:\ClusterStorage\" + $args[0].Name) } -Args $csv  | Out-Null
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

