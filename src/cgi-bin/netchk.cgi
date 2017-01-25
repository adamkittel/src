#!/usr/local/bin/perl

print "Content-type: text/html\n";
print "\n";
print "<HTML><BODY BACKGROUND=/~smmtoprd/images/icons/whpaper.gif><HR>";
open(HOSTSFILE, "hosts.list") || die print "DAMNIT<BR>";
@HOST=<HOSTSFILE>;
$HOSTCOUNT=@HOST;
$DATE=`date`;
@DATE2=split(' ',$DATE);

###PING SYSTEMS###
for($i=0;$i<=$HOSTCOUNT;$i++)
{
    $STAT=0;
    if($HOST[$i] =~ /\#/)
    {
	#not what i want yet
    }
    else
    {
        chop($HOST[$i]);
        $PING=`/usr/sbin/ping -vs $HOST[$i]`;
	print "$PING<br>";
	if($PING =~ /no answer/)
	{
	    print "NO ANSWER FROM $HOST[$i]\n<BR>";
	    $STAT=1;
	}
    }
}
if($STAT == 0){print "ALL SYSTEMS ALIVE\n<BR>";}


close(HOSTSFILE);

