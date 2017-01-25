#!/bin/bash

BINPREFIX='/opt/cft'
CLUSTER_MVIP='mvip.etc.hosts'
CLUSTER_ADMIN='admin'
CLUSTER_ADMIN_PASS='admin'
CLUSTER_ACCOUNT='sqd'
INIT_SECRET='solidfire1234'
TARG_SECRET='1234solidfire'
VOL_CNT='5'
VOL_PREFIX='SQD'
LOGFILE='/var/log/SQD-vmwBase.log'

for VOL_SIZE in 5 10 20 40
do
	RETURN=`/usr/bin/python ${BINPREFIX}/create_volumes.py --mvip=${CLUSTER_MVIP} --user=${CLUSTER_ADMIN} --pass=${CLUSTER_ADMIN_PASS} --volume_prefix=${VOL_PREFIX}${VOL_SIZE} --volume_count=${VOL_CNT} --volume_size=${VOL_SIZE}00 --512e --account_name=${CLUSTER_ACCOUNT}`

	echo ${RETURN} >> ${LOGFILE}

	if [[ ${RETURN} != *PASS* ]]
 	then
		echo "FAIL. ${RETURN}"
		exit 1 
	fi
done

