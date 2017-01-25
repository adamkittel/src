#!/bin/bash

BINPREFIX='/opt/cft'
CLUSTER_MVIP='mvip.etc.hosts'
CLUSTER_ADMIN='admin'
CLUSTER_ADMIN_PASS='admin'
VOLGRP='sqdVAG'
VOL_PREFIX='SQD'
LOGFILE='/var/log/SQD-vmwBase.log'

RETURN=`/usr/bin/python ${BINPREFIX}/add_volumes_to_volgroup.py --mvip=${CLUSTER_MVIP} --user=${CLUSTER_ADMIN} --pass=${CLUSTER_ADMIN_PASS} --volgroup_name=${VOLGRP} --volume_regex=${VOL_PREFIX}`

echo ${RETURN} >> ${LOGFILE}

if [[ ${RETURN} != *PASS* ]]
 then
	echo "FAIL. ${RETURN}"
	exit 1 
fi

