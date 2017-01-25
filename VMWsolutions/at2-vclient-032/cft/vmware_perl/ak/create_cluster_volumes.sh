#!/bin/bash

BINPREFIX='/opt/cft'
CLUSTER_MVIP='mvip.etc.hosts'
CLUSTER_ADMIN='admin'
CLUSTER_ADMIN_PASS='admin'
CLUSTER_ACCOUNT='sqd'
INIT_SECRET='solidfire1234'
TARG_SECRET='1234solidfire'
VOL_SIZE='2048'
VOL_CNT='10'
VOL_PREFIX='SQD'
LOGFILE='/var/log/SQD-create_cluster_volumes.log'

RETURN=`/usr/bin/python ${BINPREFIX}/create_volumes.py --mvip=${CLUSTER_MVIP} --user=${CLUSTER_ADMIN} --pass=${CLUSTER_ADMIN_PASS} --volume_prefix=${VOL_PREFIX} --volume_count=${VOL_CNT} --volume_size=${VOL_SIZE} --512e --account_name=${CLUSTER_ACCOUNT}`

echo ${RETURN} >> ${LOGFILE}

if [[ ${RETURN} != *PASS* ]]
 then
	echo "FAIL. ${RETURN}"
	exit 1 
fi

