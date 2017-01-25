#!/bin/ksh
# automagicly run grits on mounted filesystems in the 
# grits config_file

if (($# < 1))
then
	print "usage: fvt-grits.ksh [GRITS base directory]\n"
	print "example: fvt-grits.ksh /GRITS\n"
	exit 0
fi

# set some global variables
STAMP=`date +%m-%d-%y.%H:%M:%S`
GBASEDIR=$1
GCONFIG="$GBASEDIR/config_file"
GCONFIGBAK=${GCONFIG}.${STAMP}
GCPDONE=${GCONFIG}.DONE
TMPCONFIG="/tmp/config_file"

# see if grits is still running 
# if not clean up from a previous run
PROC=`ps -ef | grep "java GRITS"|grep -v grep`
if (($? == 0))
then
	echo "\tGRITS is currently running.....exiting\n"
	exit 0
fi

/usr/bin/rm -f $TMPCONFIG
/usr/bin/touch $TMPCONFIG

if [[ ! -f $GCPDONE ]]
then
	/usr/bin/cp $GCONFIG $GCONFIGBAK
	/usr/bin/touch $GCPDONE
fi

# gather mount points from config_file
MOUNTPOINTS=`awk '{print $1}' $GCONFIG | grep -v '#'`

# check mount points for mounted filesystems
for MP in `echo $MOUNTPOINTS`
do
	echo "\tChecking $MP"
	grep $MP /etc/mnttab >/dev/null 2>&1
	if (($? >= 1))
	then
		echo "\t$MP not mounted. Attempting to mount"
		/sbin/mount $MP >/dev/null 2>&1
		if (($? >= 1))
		then
			echo "\t$MP failed to mount. Maybe not in vfstab??"
			echo "\t$MP will not be used\n"
		else
			echo "\t$MP successfuly mounted"
			grep $MP $GCONFIG >> $TMPCONFIG
		fi
	else
		echo "\t$MP mounted and usable\n"
		grep $MP $GCONFIG >> $TMPCONFIG
	fi
done

if [[ ! -s $TMPCONFIG ]]
then
	echo "\n\n\tMASSIVE FAILURE: temp config_file could not be built."
	echo "\tCheck your original config_file for correct mount points"
else
	/usr/bin/cp $TMPCONFIG $GCONFIG
	echo "\n\n\tNew config_file is done. Ready to run GRITS....\n"
	cd $GBASEDIR
	$GBASEDIR/run_cli
fi

