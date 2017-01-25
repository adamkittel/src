#!/usr/bin/ksh
# gather and present info to paste into a bug

bug_info()
{ 
	print "Retrieving info........\n\n"
	STADEVER=`pkginfo -l SUNWstade | grep PSTAMP`
	SAPTCH=`patchadd -p | grep 11765|cut -c1-18`
	STADEHOSTS=`/opt/SUNWstade/bin/ras_admin host_list| cut -c1-60`
	STADEDEVS=`/opt/SUNWstade/bin/ras_admin device_list | cut -c1-65`
	#STADEDEVS=`/opt/SUNWstade/bin/ras_admin device_list | cut -c21-65`
	SOLVER=`uname -a`	
	PERLVER=`/opt/SUNWstade/bin/perl -v|grep "This is perl"|cut -c8-60`

	print "********** TEST CONFIG INFO **********"  
	print "$SOLVER"
	print "$SAPTCH"
	print "$PERLVER"
	print "$STADEVER"
	print "\n$STADEHOSTS"
	print "\n$STADEDEVS"
	print "\nras_snap: $RASSNAPDIR"
	print "UE test case:  $UECASE"
	print "********* END CONFIG INFO ************"
}

print "Please enter the path to the ras snap (enter if none)"
read RASSNAPDIR
print
print "Please enter the UE test case number (enter if none)"
read UECASE

bug_info

