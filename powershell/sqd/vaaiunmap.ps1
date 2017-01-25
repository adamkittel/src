$esxcli = Get-EsxCli -VMHost "hostname here"
$esxcli.storage.vmfs.unmap(200, "datastore name here", $null)
