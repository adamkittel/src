#!/usr/local/bin/perl
 
print "Content-type: text/html\n";
print "\n";
print "<FORM METHOD=POST ACTION=\"http://SUMMITraksec/cgi-bin/cgiwrap/~smmtoprd/bin/akittel/cal3.cgi\">";
print "<HTML><TITLE>Schedualer</TITLE>";
print "<BODY BACKGROUND=/~smmtoprd/images/icons/whpaper.gif>\n";
print "<h3>Schedual</h3>\n";
print "\n";

#get passed data
read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
 
#break it into pairs (name=value)
@pairs = split(/&/, $buffer);
 
@name="";
@value="";
@tmp="";
$i=0;
 
#run it through and extract single vars + replace "+" with " " and %xx with chars
 
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
    print"<input type=\"hidden\" name=\"value$i\" value=\"$value[$i]\">";
    $i++;
} #foreach

print "<TABLE Border=1 Cellpadding=2 cellspacing=0 width=55%>";
for($i=0;$i<@value;$i++)
{
    print "<tr><td>@value[$i]</td><td>@value[$i+1]</td><td>@value[$i+2]</td></tr>";
    $i=$i+2;
}
print "</table>";
print "<br>If this is correct click submit <br>otherwise click back and edit<br>";
print "<input type=\"submit\">";
#open(FILE,">schedual");
#print FILE "
print "</BODY BACKGROUND=/~smmtoprd/images/icons/whpaper.gif></form></html>\n";

