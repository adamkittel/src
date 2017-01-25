#!/usr/local/bin/perl

open(SRC,@ARGV[0]);
@src = <SRC>;
close(SRC);
$a = @src;

for($i=0;$i<=$a;$i++)
{
    $src[$i] =~ s/COMMENT/Comment/;
    print $src[$i];
}
