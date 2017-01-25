#!/usr/bin/perl
# this is a search and replace tool
# usage [search_pattern] [replacement_text] optional[file]
# without the file option it will make changes in the entire 
# directory

if($#ARGV < 0){print "usage: snr.pl [search_pattern] [replacement_text] optional[file\n"; exit;}
    
if($#ARGV > 1)
{
    open(SRC,"$ARGV[2]");
    @src=<SRC>;
    close(SRC);
    open(SRC,">$ARGV[2]");
    for($a=0;$a<=@src;$a++)
    {
	if(@src[$a] eq /@ARGV[0]/)
	{
	    @src[$a] eq s/@ARGV[0]/@ARGV[1]/;
	    print "@src Line $a: @src[$a]";
	}
	print SRC "@src[$a]";
    }
close(SRC);
} else {
    opendir(DIR,".");
    @file=readdir(DIR);
    for($i=2;$i<=@file;$i++)
    {
	open(SRC,"@file[$i]");
	@src=<SRC>;
	close(SRC);
	open(SRC,">@file[$i]");
	for($a=0;$a<=@src;$a++)
	{
	    if(@src[$a] eq /@ARGV[0]/)
	    {
		@src[$a] eq s/@ARGV[0]/@ARGV[1]/;
		print "@file[$i] Line $a: @src[$a]";
	    }
	    print SRC "@src[$a]";
	}
	close(SRC);
    }
}
