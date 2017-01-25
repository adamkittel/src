#!/usr/local/bin/perl
 
print "Content-type: text/html\n";
print "\n";
print "<FORM METHOD=POST ACTION=\"http://summitraksec/cgi-bin/cgiwrap/~smmtoprd/bin/akittel/cal2.cgi\">";
print "<HTML><TITLE>Schedualer</TITLE>";
print "<BODY BACKGROUND=/~smmtoprd/images/icons/whpaper.gif>\n";
print "<h3>Schedual</h3>\n";
print "\n";

$DATE=`date`;
@DATE2=split(' ',$DATE);
$COUNT=@DATE2;
 
@opers=("Ryan Crapo","Ryan Shannon","Mike Burris","Jerel Blakely","Alan Grimes","Greg Tokarski","Oahnn Doung","Adam Kittel","Patricia Billinger","Maxwell Klute","Dave Whittacker","Chuck Miller");

print "<TABLE Border=1 Cellpadding=2 cellspacing=0 width=75%>";
for($i=0;$i<@opers;$i++)
{
    print "<input type=\"hidden\" name=\"oper\" value=\"@opers[$i]\">";
    print "<tr><td>@opers[$i]</td> <td>Days <select name=\"days\"> \
                           <option>Sun-Wed \
                           <option>Wed-Sat \
                           </select></td> \
           <td>Times <select name=\"times\"> \
           <option>07:00-18:00 \
           <option>14:00-01:00 \
           <option>23:00-10:00 \
           </select></td></tr>";
}
print "</table>";
print "<input type=\"submit\" value=\"submit\">";

print "</BODY BACKGROUND=/~smmtoprd/images/icons/whpaper.gif></form>\n";
