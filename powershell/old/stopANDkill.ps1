for($x=1; $x -le 60; $x++) {
Stop-VM -Confirm:$false -vm qossioc3-${x}
Remove-VM -Confirm:$false qossioc3-${x} -DeletePermanently
}
