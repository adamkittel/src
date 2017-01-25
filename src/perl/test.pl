#!/usr/bin/perl
open(HOSTSFILE, "/home/oper/bin/.hosts.list") || die print "DAMNIT";
@HOST=<HOSTSFILE>;
$HOSTCOUNT=@HOST;

###CHECK FOR DEFUNCT PROCESSES###
for($i=0;$i<=$HOSTCOUNT;$i++)
{
    if($HOST[$i] =~ /\#/)
    {
        #not what i want yet
    }
    else
    {
	chop($HOST[$i]);
	$DEFUNCT=`rsh -l oper $HOST[$i] ps -eaf | grep defunct`;
	print "$HOST[$i] $DEFUNCT\n";
    }
}
