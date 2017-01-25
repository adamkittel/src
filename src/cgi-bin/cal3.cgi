#!/usr/local/bin/perl
 
print "Content-type: text/html\n";
print "\n";

$DATE=`date`;
@DATE2=split(' ',$DATE);
$COUNT=@DATE2; 

#get passed data
read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
 
#break it into pairs (name=value)
@pairs = split(/&/, $buffer);

$DATE=`date`;
@DATE2=split(' ',$DATE);
$COUNT=@DATE2; 

@name="";
@value="";
@tmp="";
$i=0;
 
foreach $pair (@pairs)
{
    #split into pairs
    ($name[$i], $value[$i]) = split(/=/, $pair);
    #switch + to " "
    $value[$i] =~ tr/+/ /;
    #translate rest of html eskape seqs.
    $value[$i] =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    #escape " and `
    $value[$i] =~ s/\"/\\\"/g;
    $value[$i] =~ s/\`/\\\`/g;
    #print "value $i = $value[$i]<br>";
    #print"<input type=\"hidden\" value=\"@value[$i]>";
    $i++;
} #foreach

$user="$ENV{'REMOTE_USER'}";
$file="den-sched.html";
$completepath="/home/smmtoprd/html\_internal/bin/akittel/$file";


$a=0;
for($i=0;$i<@value;$i++)
{
    @oper[$a]= "@value[$i] @value[$i+1] @value[$i+2]\n";
    $i=$i+2;
    $a++;
}

#write to html file
open(SCHED,">$completepath");


print SCHED qq ! <HTML><TITLE>Schedualer</TITLE>\n
    <BODY BACKGROUND=/~smmtoprd/images/icons/whpaper.gif>\n
    <h3>Schedual</h3>\n
    <table Border width=100%> <tr align=center valign=center>\n
    <TD><H2>Name</H2></TD><TD><H2>Mon</H2></TD><TD><H2>Tues</H2></TD><TD><H2>Wed</H2></TD><TD><H2>Thurs</H2></TD><TD><H2>Fri</H2></TD><TD><H2>Sat</H2></TD><TD><H2>Sun</H2></TD></TR> \n! ;

for($i=0;$i<=@oper;$i++)
{
    print SCHED "<TR ALIGN=CENTER VALIGN=CENTER>\n";
    @tmp=split(' ',@oper[$i]);
    if(@oper[$i] =~ /Sun-Wed/)
    {
	$tmp1="<td><h3>@tmp[0] @tmp[1]</h3></td><td>@tmp[3]</td><td>@tmp[3]</td><td>@tmp[3]</td><td>-</td><td>-</td><td>-</td><td>@tmp[3]</td></tr>";
    } 
    if(@oper[$i] =~ /Wed-Sat/)
    {
	$tmp1="<td><h3>@tmp[0] @tmp[1]</h3></td><td>-</td><td>-</td><td>@tmp[3]</td><td>@tmp[3]</td><td>@tmp[3]</td><td>@tmp[3]</td><td>-</td>";
    }
    print SCHED "$tmp1\n";
    $tmp1="";
}
print SCHED qq ! </table></BODY BACKGROUND=/~smmtoprd/images/icons/whpaper.gif></html>\n !;
close(SCHED);
open(SCHED,"$completepath");
@input=<SCHED>;
print "@input";



