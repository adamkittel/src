 $esxhost = '172.26.254.176'
 1..20 | foreach {
$vm = $hostprefix + $clustername + 'Fulllinux' + $num
 New-VM -Datastore 176HackathonDSCmax -VMHost $esxhost -VM ubuntuServer -Name $vm -RunAsync
 $num++
}