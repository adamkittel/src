#!/bin/bash

BINPREFIX='/opt/cft'
VMWBIN='/opt/cft/vmware_perl'
LOGFILE='/var/log/SQD-vmwBase.log'
VMW_CLUSTER='sqdCluster'
VCENTER='vcenter.etc.hosts'
HOST=`grep vmhost /etc/hosts|awk '{print $1}'`

for DS in `/usr/bin/perl ${VMWBIN}/vmware_list_datastores.pl --cluster=${VMW_CLUSTER} --bash --mgmt_server=${VCENTER}`
	do
	for((x=0;$x<2;x++))
	do
		NUM=`echo $[ 1 + $[ RANDOM % 9999 ]]`
		/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=ubuntuServer${NUM} --datastore=${DS} --mgmt_server=${VCENTER} --nopoweron --source_vm=ubuntuServer  --vmhost=${HOST} & 
		sleep 5
		#echo ${UBUNTU} >> ${LOGFILE}.ubuntu

		#if [[ ${UBUNTU} != *PASS* ]]
 		#then
		#	echo "FAIL. ${UBUNTU}"
		#fi
		#WIN7=`/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=Windows7${x} --datastore=${DS} --mgmt_server=${VCENTER} --nopoweron --source_vm=Windows7  --vmhost=${HOST} &`
		/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=Windows7${NUM} --datastore=${DS} --mgmt_server=${VCENTER} --nopoweron --source_vm=Windows7  --vmhost=${HOST} & 
		sleep 5
		#echo ${WIN7} >> ${LOGFILE}.windows7

		#if [[ ${WIN7} != *PASS* ]]
 		#then
		#	echo "FAIL. ${WIN7}"
		#fi
		#ADSVR=`/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=ADserver${x} --datastore=${DS} --mgmt_server=${VCENTER} --nopoweron --source_vm=ADserver  --vmhost=${HOST} &`
		/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=ADserver${NUM} --datastore=${DS} --mgmt_server=${VCENTER} --nopoweron --source_vm=ADserver  --vmhost=${HOST} & 
		sleep 5
		#echo ${ADSVR} >> ${LOGFILE}.ubuntu

		#if [[ ${ADSVR} != *PASS* ]]
 		#then
		#	echo "FAIL. ${ADSVR}"
		#fi
	done
done

