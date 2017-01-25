#!/bin/bash
# clone vm's to datastores ending in 02 and 04 to test out sdrs

BINPREFIX='/opt/cft'
VMWBIN='/opt/cft/vmware_perl'
LOGFILE='/var/log/SQD-vmwBase.log'
VMW_CLUSTER='sqdCluster'
VCENTER='vcenter.etc.hosts'
HOST=`grep vmhost /etc/hosts|awk '{print $1}'`
DS='unmap-clone'
#for DS in unmap unmap3
#	do
	for((x=0;$x<200;x++))
	do
		NUM=`echo $[ 1 + $[ RANDOM % 9999 ]]`
		/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=ubuntuServer${NUM} --datastore=${DS} --mgmt_server=${VCENTER} --source_vm=ubuntuServer --thin --vmhost=${HOST} & 
		sleep 5
		#echo ${UBUNTU} >> ${LOGFILE}.ubuntu

		#if [[ ${UBUNTU} != *PASS* ]]
 		#then
		#	echo "FAIL. ${UBUNTU}"
		#fi
		/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=Windows7${NUM} --datastore=${DS} --mgmt_server=${VCENTER} --nopoweron --source_vm=Windows7 --thin --vmhost=${HOST} & 
		sleep 5
		#echo ${WIN7} >> ${LOGFILE}.windows7

		#if [[ ${WIN7} != *PASS* ]]
 		#then
		#	echo "FAIL. ${WIN7}"
		#fi
		/usr/bin/perl ${VMWBIN}/vmware_clone_vm.pl --clone_name=ADserver${NUM} --datastore=${DS} --mgmt_server=${VCENTER} --nopoweron --source_vm=ADserver --thin --vmhost=${HOST} & 
		sleep 5
		#echo ${ADSVR} >> ${LOGFILE}.ubuntu

		#if [[ ${ADSVR} != *PASS* ]]
 		#then
		#	echo "FAIL. ${ADSVR}"
		#fi
	done
#done

