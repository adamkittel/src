for($x=1; $x -le 10; $x++) {
	New-VM -vmhost 192.168.129.81 -Name qossioc2-${x} -Template ubuntuServer -Datastore qossioc-2
	start-vm -vm qossioc2-${x}
}

for($x=1; $x -le 10; $x++) {
	Stop-VM -Confirm:$false -vm qossioc2-${x}
	Remove-VM -Confirm:$false qossioc2-${x} -DeletePermanently
}
