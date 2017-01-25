#!/bin/bash

SCRIPT_PATH='/opt/cft/ak_vmware'
VCENTER='192.168.129.147'
CHAP_NAME='sqd'
INIT_SECRET='solidfire123'
TARG_SECRET='123solidfire'
SVIP='10.10.8.165'

HOST_LIST=`/usr/bin/perl ${SCRIPT_PATH}/vmware_list_hosts.pl --cluster_name=sqd --csv --mgmt_server=${VCENTER}|awk -F ',' '{$1=""; print $0}'`
echo ${HOST_LIST}

CNT=0

for CNT in "${HOST_LIST[@]}"
do
	/usr/bin/perl ${SCRIPT_PATH}/vmware_setup_chap.pl --chap_name=${CHAP_NAME} --init_secret=${INIT_SECRET} --mgmt_server=${VCENTER} --svip=${SVIP} --targ_secret=${TARG_SECRET} --vmhost=${HOST_LIST[${CNT}]}
	let CNT=$CNT+1
done

#while [ ${CNT} -lt ${#HOST_LIST[@]} ] 
#do 
##	FIELD=`echo ${HOST_LIST} | awk -F',' '{print ${CNT}'`
#	HOST=`/usr/bin/perl ${SCRIPT_PATH}/vmware_setup_chap.pl --chap_name=${CHAP_NAME} --init_secret=${INIT_SECRET} --mgmt_server=${VCENTER} --svip=${SVIP} --targ_secret=${TARG_SECRET} --vmhost=${HOST_LIST[${CNT}]}` 
#	echo "Host ${HOST_LIST[${CNT}]} complete "
#	let CNT=${CNT}+1
#done


