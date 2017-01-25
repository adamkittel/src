#!/bin/bash

if [ ! $# == 2 ]; then
	echo "usage ${0} vmprefix operation [poweron, poweroff, suspend, reset, reboot, shutdown, standby]"
	exit 1
fi

VMPREFIX=$1
POWEROP=$2
BINPREFIX='/opt/cft'
VMWBIN='/opt/cft/vmware_perl'
LOGFILE='/var/log/SQD-vmwBase.log'
VCENTER='vcenter.etc.hosts'
HOST=`grep vmhost /etc/hosts|awk '{print $1}'`

/usr/bin/perl ${VMWBIN}/vminfo.pl --server ${VCENTER} --username sqd --password solidfire > /tmp/vmlist

for VM in `grep Name /tmp/vmlist | grep -v vmPathName: | awk '{print $2}' |grep ${VMPREFIX}`
	do
	/usr/bin/perl ${VMWBIN}/vmcontrol.pl --server 192.168.129.16 --username sqd --password solidfire --operation ${POWEROP} --vmname ${VM} &
done

