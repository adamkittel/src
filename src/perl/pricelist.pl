#!/usr/local/bin/perl

open(SRC,"/home/akittel/doc/misc/adam.pricelist");
@pricelist=<SRC>;
close(SRC);
$size=@pricelist;

for($i=0;$i<=$size;$i++)
{
    @pricelist =~ s/^L/' '/;
    if(@pricelist[$i] =~ /\$/)
    {
	@b=split(/\$/,@pricelist[$i]);
	@b[1]=@b[1]+(@b[1]*.20);
	@pricelist[$i]="@b[0]\$@b[1]\n";
    }
    print @pricelist[$i];
}
