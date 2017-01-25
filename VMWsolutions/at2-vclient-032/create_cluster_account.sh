#!/bin/bash

BINPREFIX='/opt/cft'
CLUSTER_MVIP='mvip.etc.hosts'
CLUSTER_ADMIN='admin'
CLUSTER_ADMIN_PASS='admin'
CLUSTER_ACCOUNT='sqd'
INIT_SECRET='solidfire1234'
TARG_SECRET='1234solidfire'
LOGFILE='/var/log/SQD-vmwBase.log'

RETURN=`/usr/bin/python ${BINPREFIX}/create_account.py --mvip=${CLUSTER_MVIP} --user=${CLUSTER_ADMIN} --pass=${CLUSTER_ADMIN_PASS} --account_name=${CLUSTER_ACCOUNT} --initiator_secret=${INIT_SECRET} --target_secret=${TARG_SECRET} --strict`

echo ${RETURN} >> ${LOGFILE}

if [[ ${RETURN} != *PASS* ]]
 then
	echo "FAIL. ${RETURN}"
	exit 1 
fi

