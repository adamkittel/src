#!/usr/local/bin/perl

open(HOSTSFILE, "/home/oper/bin/.hosts.list") || die print "DAMNIT";
@HOST=<HOSTSFILE>;
$HOSTCOUNT=@HOST;
$DATE=`date`;
@DATE2=split(' ',$DATE);

###PING SYSTEMS###
for($i=0;$i<$HOSTCOUNT;$i++)
{
    $STAT=0;
    if($HOST[$i] =~ /\#/)
    {
	#not what i want yet
    }
    else
    {
        chop($HOST[$i]);
        $PING=`/usr/sbin/ping $HOST[$i]`;
	if($PING =~ /no answer/)
	{
	    print "NO ANSWER FROM $HOST[$i]\n";
	    $STAT=1;
	} else {
	    print $PING;
	}
    }
}
#if($STAT == 0){print "ALL SYSTEMS ALIVE\n";}

###CHECK FOR DEFUNCT PROCESSES###
for($i=0;$i<$HOSTCOUNT;$i++)
{
    if($HOST[$i] =~ /\#/)
    {
        #not what i want yet
    }
    else
    {
	@DEFUNCT=`rsh -l oper $HOST[$i] ps -eaf | grep defunct`;
	$DEFNUM=@DEFUNCT;
	if($DEFNUM > 50)
	{
	    print "$HOST[$i]\n@DEFUNCT";
	}
    }
}

###CHECK MESSAGES###
for($i=0;$i<$HOSTCOUNT;$i++)
{
    if(@HOST[$i] =~ /\#/)
    {
	#not what i want
    } else {
	@HOSTMSG=`rsh -l oper @HOST[$i] tail -3 /var/adm/messages`;
	for($c=0;$c<=3;$c++)
	{
	    if($HOSTMSG[$c] =~ /failed|not responding|No keep-alive|Errors|Periodic head cleaning/)
	    {
		print "$HOSTMSG[$c]\n";
	    }
	}
    }
}

###CHECK DISKSPACE###
for($i=0;$i<$HOSTCOUNT;$i++)
{
    if(@HOST[$i] =~ /\#/)
    {
	#not what i want
    } else {
	@DISKSPACE=`rsh -l oper @HOST[$i] df -k`;
	$COUNT=@DISKSPACE;
	for($a=0;$a<=$COUNT;$a++)
	{
	    @TMP=split(' ',$DISKSPACE[$a],4);
	    @TMP2=split(' ',$TMP[3]);
	    chop($TMP2[1]);
	    if($TMP2[1] > 93)
	    {
		print "WARNING @HOST[$i] @TMP2\n";
	    }
	}
    }
}

###CHECK FOR RECENT REBOOT
for($i=0;$i<$HOSTCOUNT;$i++)
{
    if($HOST[$i] =~ /\#/)
    {
	#not what i want
    } else {
	$LASTBOOT=`rsh -l oper $HOST[$i] who -b`;
	@LASTBOOT2=split(' ',$LASTBOOT);
	if($LASTBOOT2[3] == $DATE2[1])
	{
	    if($LASTBOOT2[4] == $DATE2[2])
	    {
		print "$HOST[$i]\t @LASTBOOT2\n";
	    }
	}
    }
}

close(HOSTSFILE);

