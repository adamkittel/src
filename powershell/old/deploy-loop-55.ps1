for($x=1; $x -le 100; $x++) {
	New-VM -vmhost 192.168.133.115 -Name linux-unmap-${x} -Template ubuntuServer -Datastore unmap
	start-vm -vm linux-unmap-${x}
}

for($x=1; $x -le 100; $x++) {
	Stop-VM -Confirm:$false -vm linux-unmap-${x}
	Remove-VM -Confirm:$false linux-unmap-${x} -DeletePermanently
}

for($x=1; $x -le 100; $x++) {
	New-VM -vmhost 192.168.133.126 -Name 2012-unmap-${x} -Template ADserver -Datastore unmap
	start-vm -vm 2012-unmap-${x}
}

for($x=1; $x -le 100; $x++) {
	Stop-VM -Confirm:$false -vm 2012-unmap-${x}
	Remove-VM -Confirm:$false 2012-unmap-${x} -DeletePermanently
}
