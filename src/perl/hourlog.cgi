From - Tue May  6 19:55:40 1997
Received: from viper.tci.com (viper.tci.com [198.178.8.173]) by blackhole.dimensional.com (8.7.6/8.6.12) with SMTP id JAA13151 for <akittel@dimensional.com>; Tue, 6 May 1997 09:16:14 -0600 (MDT)
Posted-Date: Tue, 6 May 1997 09:16:14 -0600 (MDT)
Received-Date: Tue, 6 May 1997 09:16:14 -0600 (MDT)
Received: by viper.tci.com; id JAA29022; Tue, 6 May 1997 09:15:16 -0600
Received: from den-web1.tci.com(165.137.146.147) by viper.tci.com via smap (3.2)
	id xma028768; Tue, 6 May 97 09:14:56 -0600
Received: (from smmtoper@localhost)
	by den-web1.tci.com (8.8.5/8.8.5) id JAA04215
	for akittel@dimensional.com; Tue, 6 May 1997 09:15:36 -0600 (MDT)
Date: Tue, 6 May 1997 09:15:36 -0600 (MDT)
From: Smmt Oper Web Production <smmtoper@den-web1.tci.com>
Message-Id: <199705061515.JAA04215@den-web1.tci.com>
To: akittel@dimensional.com
Status: RO
X-Mozilla-Status: 0001
Content-Length: 2825

#!/usr/local/bin/perl
#hourlogentrystart.cgi

print "Content-type: text/html\n\n";
print "<HTML><HEAD><TITLE>Log Entry</TITLE></HEAD>";
print "<BODY BACKGROUND=/~smmtoper/images/backgrounds/bg.1 BGCOLOR=white TEXT=black ALINK=yellow VLINK=brown LINK=red>";
$date=`date "+%b%d %H:%M"`;
chop($date);
$value="none\n";
$user="$ENV{'REMOTE_USER'}";

print "<FONT COLOR=blue SIZE=7>Hourly Log Entry</FONT><HR>";
print "<IMAGE BORDER=0 SRC=/cgi-bin/cgiwrap/~smmtoper/bin/cnt-log/t1.cgi?logs_hourlogentry>";

print "<FORM METHOD=post ACTION='/cgi-bin/cgiwrap/~smmtoper/bin/3t/submit.cgi'>";
print "<TABLE BORDER=1 WIDTH=50%><TR>";
print "<TD>RSM ";
print "<INPUT TYPE=radio NAME=rsm VALUE=ok>OK";
print "<INPUT TYPE=radio NAME=rsm VALUE=problem>Problem";
print "</TD><TD><TEXTAREA NAME=rsmtext ROWS=1 COLS=50% WRAP=on></TEXTAREA></TD></TR>";

print "<TD>SNM ";
print "<INPUT TYPE=radio NAME=snm VALUE=ok>OK";
print "<INPUT TYPE=radio NAME=snm VALUE=problem>Problem";
print "</TD><TD><TEXTAREA NAME=snmtext ROWS=1 COLS=50% WRAP=on></TEXTAREA></TD></TR>";

print "<TD>CPPV ";
print "<INPUT TYPE=radio NAME=cppv VALUE=ok>OK";
print "<INPUT TYPE=radio NAME=cppv VALUE=problem>Problem";
print "</TD><TD><TEXTAREA NAME=cppvtext ROWS=1 COLS=50% WRAP=on></TEXTAREA></TD></TR>";

print "<TD>Tivoli ";
print "<INPUT TYPE=radio NAME=tivoli VALUE=ok>OK";
print "<INPUT TYPE=radio NAME=tivoli VALUE=problem>Problem";
print "</TD><TD><TEXTAREA NAME=tivolitext ROWS=1 COLS=50% WRAP=on></TEXTAREA></TD></TR>";

print "<TD>Greeley ";
print "<INPUT TYPE=radio NAME=greeley VALUE=ok>OK";
print "<INPUT TYPE=radio NAME=greeley VALUE=problem>Problem";
print "</TD><TD><TEXTAREA NAME=greeleytext ROWS=1 COLS=50% WRAP=on></TEXTAREA></TD></TR>";

print "<TD> Pings ";
print "<INPUT TYPE=radio NAME=ping VALUE=ok>OK";
print "<INPUT TYPE=radio NAME=ping VALUE=problem>Problem";
print "</TD><TD><TEXTAREA NAME=pingtext ROWS=1 COLS=50% WRAP=on></TEXTAREA></TD></TR>";

print "<TD> Mail ";
print "<BR><INPUT TYPE=radio NAME=mail VALUE=red>Red";
print "<BR><INPUT TYPE=radio NAME=mail VALUE=yellow>Yellow";
print "<INPUT TYPE=radio NAME=mail VALUE=green>Green";
print "</TD><TD><TEXTAREA NAME=mailtext ROWS=1 COLS=50% WRAP=on></TEXTAREA></TD></TR>";

print "<TD>Additional Comments </TD>";
print "<TD><TEXTAREA NAME=comments ROWS=5 COLS=50% WRAP=on>$value</TEXTAREA></TD></TR>";
print "</TABLE>";
print "<INPUT TYPE=hidden NAME=search VALUE=yes>";
print "<INPUT TYPE=hidden NAME=group VALUE=hlog>";
print "<INPUT TYPE=hidden NAME=user VALUE=$user>";
print "<p><INPUT TYPE=SUBMIT VALUE='SUBMIT LOG'>";

print "<P><P><A HREF=/~smmtoper/docs/main/logo/logs><IMG SRC=/~smmtoper/images/buttons/back.gif>Back to Logs</A>";
print "<A HREF=/~smmtoper/docs/main/><IMG BORDER=0 SRC=/~smmtoper/images/buttons/home.gif>Back to Oper HomePage</A><BR>";

print "</BODY></HTML>";
