#!/usr/local/bin/perl

$DATE=`date`;
@DATE2=split(' ',$DATE);
$COUNT=@DATE2;

for($a=0;$a<=$COUNT;$a++)
{
    print "Field $a = @DATE2[$a]\n";
}
