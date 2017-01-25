#!/usr/local/bin/perl
# IF YOU ARE SICK OF DELETEING JUNK MAIL, RUN THIS ON STARTUP!!!
#/////////
#// modify the file lines 
#/////////
#open(MAIL,"/var/mail/akittel");
open(MAIL,"/home/akittel/nsmail/Inbox");
open(JUNK,">/home/akittel/nsmail/OPER");
open(OK,">/home/akittel/nsmail/OK");
open(ORIGINAL,">/home/akittel/nsmail/ORIGINAL");

#put mail jfile in array
@MAILARRAY=<MAIL>;
#put array count in variable, for line count
$LINECOUNT=@MAILARRAY;
#print $LINECOUNT;

#create backup mail file if your using mail from /var/mail
#comment out this section if your using ~/nsmail/Inbox
for($i=0;$i<=$LINECOUNT;$i++)
{
    select(ORIGINAL);
    print $MAILARRAY[$i];
}
$a=0;
$b=0;
$c=0;
$i=0;
while($a < $LINECOUNT)
{
    $b++;
    do
    {
	$BUF[$c]=$MAILARRAY[$i];
	$i++; $c++;
    }until @MAILARRAY[$i] =~ /From / || $i==$LINECOUNT;

    if(@MAILARRAY[$a] =~ /From Mailer-Daemon|From root|From smmtoper|From oper|From akittel/)
    {
	select(JUNK);
	print @BUF;
	@BUF="";
    } else {
	select(OK);
	print @BUF;
	@BUF="";
    }
    select(STDOUT);
    #print "LINECOUNT=$LINECOUNT\n";
    #print "PROCESESSING MESSAGE $b\n";
    #print "LINE $a\n";
    $a=$i;
    $c=0;
}


close(OK);
close(JUNK);
close(MAIL);
close(ORIGINAL);
