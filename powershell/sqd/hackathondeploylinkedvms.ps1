$esxhost = '172.26.254.176'
$vcenter = '192.168.129.144'
[string]$snap = (Get-Snapshot -vm ubuntuparent).name
 1..20 | foreach {
$vm = $hostprefix + $clustername + 'linkedubuntu' + $num
 New-VM -Datastore '176HackathonDSCdefault' -LinkedClone -ReferenceSnapshot $snap -VM ubuntuparent -VMHost $esxhost -Name $vm -RunAsync -Server $vcenter 
 $num++
}