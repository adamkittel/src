#!/usr/bin/ksh
UID=`grep $LOGNAME /etc/passwd |awk -F":" '{print $3}'`
MYPID=`ps |grep kill |awk '{print $1}'`
print "Hi, I'm $MYPID"
for PROC in `ps -el|grep $UID |grep console |awk '{print $4}'`
	do
	PSPID=`ps |grep kill |awk '{print $1}'`
	case $PROC in
		$MYPID)
		print "That was close..."
		;;
		$PSPID)
		print "Suicide Attempt"
		;;
		
		*)
		kill -9	$PROC
		print "DEAD!"
		
	esac
	done