#!/usr/local/bin/perl

@list=('help1', 'cst1', 'bill2', 'cst2', 'disp2', 'eq2', 'xref2', 'adr2');

$home="/home/akittel/src/perl";
$b = @list;

for($i=0;$i<=$b;$i++)
{
    print "$list[$i]\n";
    $tail = `rsh -l oper den-$list[$i] ps -eaf | grep /var/log/backup`;
    print PIDLIST "$tail\n";
    if($tail ne '')
    {
	@pidarray = split(' ',$tail);
	print "killing $pidarray[1]: $pidarray[7]\n";
	system("rsh -l oper den-$list[$i] kill $pidarray[1]");
    }
}

