#!/usr/local/bin/perl

open(HOSTSFILE, "/home/oper/bin/.hosts.list") || die print "DAMNIT";
open(MSGFILE,">/home/akittel/text/messages");
@HOST=<HOSTSFILE>;
$HOSTCOUNT=@HOST;

for($i=0;$i<=$HOSTCOUNT;$i++)
{
    if(@HOST[$i] =~ /\#/)
      {
	  #not what i want
      } else {
	  print @HOST[$i];
	  chop(@HOST[$i]);
	  @DISKSPACE=`rsh -l oper @HOST[$i] df -k 2> /dev/null`;
	  $COUNT=@DISKSPACE;
	  for($a=0;$a<=$COUNT;$a++)
	  {
	      @TMP=split(' ',$DISKSPACE[$a],4);
	      print $TMP[3];
	  }
	  print "\n\n";
      }
}
close(HOSTSFILE);
close(MSGFILE);
