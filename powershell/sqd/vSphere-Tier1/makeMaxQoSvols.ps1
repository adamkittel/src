
[string]$hostip = '222'
$prefix = 'maxQoS'
[string]$burstiops = '100000'
[string]$maxiops = '100000'
[string]$miniops = '15000'

$num=1

	1..20 | foreach {
		[string]$vol = $hostip + $prefix + $num
		if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) 
		{ 
			[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol | Tee-Object -Append -FilePath $statfile
			#$pass | Tee-Object -Append -FilePath $statfile
		} else { 
			$newvol = New-SFVolume -AccountID 3 -BurstIOPS $burstiops -Enable512e $true -MaxIOPS $maxiops -MinIOPS $miniops -Name $vol -GB 250
			write-output $newvol
			if($newvol.VolumeID) { 
				[string]$pass = Write-Output "PASS: created volume: " $vol $newvol.VolumeID
				#$pass | Tee-Object -Append -FilePath $statfile 
			} else {
				[string]$err = Write-Output "FAIL: Volume create failed for " $vol
				#$err | Tee-Object -Append -FilePath $errwarn 
				#$err | Out-File -Append -FilePath $statfile
			}
		}
		$num++
	}
