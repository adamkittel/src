#!/bin/ksh

infile=~oper/bin/.hosts.list
hosts=`cat $infile | grep -v "#"`

for SYS in $hosts
do
	print $SYS
	rsh -l oper $SYS 'ps -eaf|grep oper | grep tail'
	rsh -l oper $SYS 'ps -eaf|grep oper | grep tail' > ${HOME}/pid.list
	PIDLIST=`cat ${HOME}/pid.list | awk '{print $2}'`
	for i in $PIDLIST
	do	
	  print "Killing $i"
	  rsh -l oper $SYS kill ${i}
	done
	print "\nSECOND CHECK\n"
	rsh -l oper $SYS 'ps -eaf|grep oper | grep tail'
	print "\n****************\n\n"
done