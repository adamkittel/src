#!/bin/bash

if [ ! $# == 2 ]; then
	echo "usage ${0} vmprefix operation [list, revert, goto, rename, remove, removeall, create]"
	exit 1
fi

VMPREFIX=$1
SNAPOP=$2
BINPREFIX='/opt/cft'
VMWBIN='/opt/cft/vmware_perl'
LOGFILE='/var/log/SQD-vmwBase.log'
VCENTER='vcenter.etc.hosts'
HOST=`grep vmhost /etc/hosts|awk '{print $1}'`

/usr/bin/perl ${VMWBIN}/vminfo.pl --server ${VCENTER} --username sqd --password solidfire > /tmp/vmlist

ARGS="--server ${VCENTER} --username sqd --password solidfire --operation ${SNAPOP} --vmname ${VM}"

if [ ${SNAPOP} -eq 'create' ]
then
	NUM=`echo $[ 1 + $[ RANDOM % 9999 ]]`
	ARGS="--server ${VCENTER} --username sqd --password solidfire --operation ${SNAPOP} --vmname ${VM} --snapshotname ${vm}.${NUM}"	
fi

for VM in `grep Name /tmp/vmlist | grep -v vmPathName: | awk '{print $2}' |grep ${VMPREFIX}`
	do
	/usr/bin/perl ${VMWBIN}/snapshotmanager.pl ${ARGS} &
done

