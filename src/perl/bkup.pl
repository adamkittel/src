#!/usr/local/bin/perl 

if($#ARGV < 0){print "usage: bkup.pl [os] or [veritas]\n"; exit;}

$date=`date`;
@datearray=split(' ',$date);

if($datearray[2]<10)
{
    $datearray[2]="0$datearray[2]";
}

$login=getlogin;

if(@ARGV[0] eq 'os')
{
    @os=('help1', 'cst1', 'bill2', 'cst2', 'disp2', 'eq2', 'xref2', 'adr2');
    
    $a=@os;
    for($i=0;$i<=$a;$i++)
    {
	system("xterm -T \"den-$os[$i] ctrl-c to exit!!!\" -geometry 80x5 -fn 6x10 -e rsh -l oper den-$os[$i] tail -f /var/log/backup/ufsbackup.$datearray[2]v &");
    }
}

if(@ARGV[0] eq 'veritas')
{
    @veritas=('bill2', 'eq2', 'cst1', 'help1', 'cst2', 'adr2', 'disp2', 'naru3', 'xref2');

    $b=@veritas;
    for($i=0;$i<=$b;$i++)
    {
	system("xterm -T \"den-$veritas[$i] ctrl-c to exit!!!\" -geometry 80x5 -fn 6x10 -e rsh -l oper den-$veritas[$i] tail -f /var/log/backup/ufsbackup.$datearray[2]v &");
    }
}
