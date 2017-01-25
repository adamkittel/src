#!/usr/local/bin/perl

if($#ARGV < 0)
{
    print "usage: txt2html.pl [text file] > [html file]"; 
    exit;
} else {
    open(SRC,"$ARGV[0]");
    @src=<SRC>;
    close(SRC);
}
$b=@src;
print $b;
for($i=0;$i<=$b;$i++)
{
    chop(@src[$i]);
    @src[$i]="@src[$i]<br>\n";
    print @src[$i];
}

	

