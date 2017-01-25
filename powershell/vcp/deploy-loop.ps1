for($x=1; $x -le 30; $x++) {
New-VM -vmhost 192.168.129.72 -Name qossioc3-${x} -Template ubuntuServer-t -Datastore qossioc-3
start-vm -vm qossioc3-${x}
}


for($x=1; $x -le 30; $x++) {
Stop-VM -Confirm:$false -vm qossioc3-${x}
Remove-VM -Confirm:$false qossioc3-${x} -DeletePermanently
}
