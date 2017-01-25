#!/bin/bash

BINPREFIX='/opt/cft'
VMWBIN='/opt/cft/vmware_perl'
LOGFILE='/var/log/SQD-vmwBase.log'
VMWBIN='/opt/cft/vmware_perl'
VMW_CLUSTER='sqdCluster'
VCENTER='vcenter.etc.hosts'

HOST=`/usr/bin/perl ${VMWBIN}/vmware_list_hosts.pl  --cluster_name=${VMW_CLUSTER} --bash --mgmt_server=${VCENTER}`
RETURN=`/usr/bin/perl ${VMWBIN}/vmware_create_datastores.pl --mgmt_server=${VCENTER} --vmhost=${HOST}[0]`
echo ${RETURN} >> ${LOGFILE}
         
if [[ ${RETURN} != *PASS* ]]
then
	echo "FAIL. ${RETURN}"
	exit 1
fi

