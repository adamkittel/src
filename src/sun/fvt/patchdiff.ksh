#!/bin/ksh
# 
# 
if (($# < 2))
then
	print "usage: patchdiff.ksh old_patch new_patch\n"
	print "example: patchdiff 117650-35c 117650-35d\n"
	exit 0
fi

PATCHDIR=/net/zila/export/dsqa/PATCHES
OLDPATCH=$1
NEWPATCH=$2

# compare file count first
/usr/bin/tput clear
echo "\n\n\tComparing file count in patches\n"
find $PATCHDIR/$OLDPATCH | cut -c42-100> /tmp/oldpatch
find $PATCHDIR/$NEWPATCH | cut -c42-100> /tmp/newpatch 

OPFCOUNT=`wc -l /tmp/oldpatch|awk '{print $1}'`
NPFCOUNT=`wc -l /tmp/newpatch|awk '{print $1}'`

echo "\tPatch $OLDPATCH has $OPFCOUNT files"
echo "\tPatch $NEWPATCH has $NPFCOUNT files"
if (($OPFCOUNT == $NPFCOUNT))
then
	echo "\tFile count is equal..."
else
	DIFF=`/usr/bin/diff -w -i  /tmp/oldpatch /tmp/newpatch 2> /dev/null`
	echo "\tDiffrences....\n$DIFF"
fi

# compare file sizes
echo "\n\tComparing files sizes\n"
for FILE in `cat /tmp/oldpatch`
do
if [[ -f $PATCHDIR/$NEWPATCH/$FILE ]]
then	
	OPSIZE=`ls -l $PATCHDIR/$OLDPATCH/$FILE|awk '{print $5}'`
	NPSIZE=`ls -l $PATCHDIR/$NEWPATCH/$FILE|awk '{print $5}'`
	if (($OPSIZE != $NPSIZE))
	then
		echo "\tFile size mismatch $FILE: \n\t\t$OLDPATCH = $OPSIZE\t$NEWPATCH = $NPSIZE"
	fi
fi
done

