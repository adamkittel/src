#!/bin/bash

BINPREFIX='/opt/cft'
VMWBIN='/opt/cft/vmware_perl'
LOGFILE='/var/log/setup_esxi_chap.sh.log'
VMWBIN='/opt/cft/vmware_perl'
VMW_CLUSTER='sqdCluster'
VCENTER='vcenter.etc.hosts'

for HOST in `/usr/bin/perl ${VMWBIN}/vmware_list_hosts.pl  --cluster_name=${VMW_CLUSTER} --bash --mgmt_server=${VCENTER}`
	do
	RETURN=`/usr/bin/perl ${VMWBIN}/vmware_rescan_iscsi.pl --mgmt_server=${VCENTER} --vmhost=${HOST}`
	echo ${RETURN} >> ${LOGFILE}

		if [[ ${RETURN} != *PASS* ]]
 		then
			echo "FAIL. ${RETURN}"
		exit 1 
		fi
done

