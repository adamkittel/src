#!/usr/local/bin/perl

open(SRC,"/home/akittel/doc/misc/coffee");
@src=<SRC>;
close(SRC);
$head="Why coffe is better than women:";

for($b=0;$b<=32;$b++)
{
    chop(@src[$b]);
    @msg="$head\n@src[$b]";
    open(TMP,">/home/akittel/doc/misc/temp1");
    print TMP @msg;
    close(TMP);
    system("mailx bagley.sandra < /home/akittel/doc/misc/temp1");
    system("mailx thompsen.sandy < /home/akittel/doc/misc/temp1");
    sleep 600;
}
