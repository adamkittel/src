param(
	[String]$mvip,
	[String]$sfadmin='admin',
	[String]$sfpass='admin',
	[String]$vcenter,
	[String]$vcadmin='admin',
	[String]$vcpass='solidfire',
	[string]$esxhost = '192.168.133.126',
	[string]$esxadmin='root',
	[string]$esxpass='solidfire'
)

$sfvcp = Get-SFAccount -UserName vcp
$vag = New-SFVolumeAccessGroup -Name vcpVAG

$num=1
1..250 | foreach {
	[string]$vol = 'vcp'+ $num
	if(Get-SFVolume -VolumeName $vol -ErrorAction SilentlyContinue) { 
		[string]$pass = Write-Output "PASS: Volume exists: " $vol.VolumeID $vol 
		$pass #| Tee-Object -Append -FilePath $checkfile
	} else {
		$newvol = New-SFVolume -AccountID $sfvcp.AccountID -BurstIOPS 15000 -Enable512e $true -MaxIOPS 15000 -MinIOPS 100 -Name $vol -Verbose -GB 100
		Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID $vag.VolumeAccessGroupID -VolumeID $newvol.volumeid
		if($newvol.VolumeID) { 
			[string]$pass = Write-Output "PASS: created volume & added to vcpVAG: " $newvol.VolumeID $vol 
			$pass #| Tee-Object -Append -FilePath $checkfile 
		} else {
			[string]$err = Write-Output "FAIL: Volume failed" $vol
			$err #| Tee-Object -Append -FilePath $errwarn 
			#$err | Out-File -Append -FilePath $checkfile
		}
	}
	$num++
}

Write-Host = 'rescanning hba. go get some coffee'
Get-VMHostStorage -RescanAllHba -VMHost $esxhost