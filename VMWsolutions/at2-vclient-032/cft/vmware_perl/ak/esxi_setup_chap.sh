#!/bin/bash

BINPREFIX='/opt/cft'
VMWBIN='/opt/cft/vmware_perl'
LOGFILE='/var/log/vmware_setup_chap.log'
VMWBIN='/opt/cft/vmware_perl'
VMW_CLUSTER='sqdCluster'
VCENTER='vcenter.etc.hosts'
INIT_SECRET='solidfire1234'
TARG_SECRET='1234solidfire'
SVIP=`grep svip.etc.hosts /etc/hosts|awk '{print $1}'`
CHAP_NAME='sqdCHAP'

for HOST in `/usr/bin/perl ${VMWBIN}/vmware_list_hosts.pl  --cluster_name=${VMW_CLUSTER} --bash --mgmt_server=${VCENTER}`
	do
	RETURN=`/usr/bin/perl ${VMWBIN}/vmware_setup_chap.pl --chap_name=${CHAP_NAME} --init_secret=${INIT_SECRET} --mgmt_server=${VCENTER} --svip=${SVIP} --targ_secret=${TARG_SECRET} --vmhost=${HOST}`
	echo ${RETURN} >> ${LOGFILE}

		if [[ ${RETURN} != *PASS* ]]
 		then
			echo "FAIL. ${RETURN}"
		exit 1 
		fi
done

