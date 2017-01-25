#!/usr/local/bin/perl


$DATE=`date`;
@DATEARRAY=split(' ',$DATE);
print $DATEARRAY[2];
if($DATEARRAY[2]<10)
{
    $DATEARRAY[2]="0$DATEARRAY[2]";
}
$login=getlogin;
@OS=('help1', 'oars1', 'cst1', 'aruc1', 'bill2', 'cst2', 'dds1', 'disp2', 'eq2', 'naru2', 'ndb2', 'oars2', 'xref2', 'bill2', 'adr2');

$a=@LIST;
print $a;
for($i=0;$i<=$a;$i++)
{
    system("xterm -T \"den-$LIST[$i] ctrl-c to exit!!!\" -geometry 80x5 -fn 6x10 -e rsh -l oper den-$LIST[$i] tail -f /var/log/backup/ufsbackup.$DATEARRAY[2]v &");
}


