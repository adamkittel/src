#!/usr/local/bin/perl

read(STDIN,$BUFFER,$ENV{'CONTENT-LENGTH'});

@STUFF=split(/&/,$BUFFER);

$i=@STUFF;

print "<HTML><BODY>";
for($a=0;$a<=$i;$a++)
{
    print @STUFF[$a];
}

print "</HTML></BODY>";

system("mailx akittel -s works");
