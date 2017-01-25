$vms = get-vm | where {$_.powerstate -eq 'PoweredOn'}
 foreach ($vm in $VMS) {
 $vcname = $vm.name
 $gosname = $vm.Guest.Hostname
 $gosname
 }