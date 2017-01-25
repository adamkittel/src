#!/usr/local/bin/perl

opendir(DIR,".");
@dirlist=readdir(DIR);
for($i=0;$i<=@dirlist;$i++)
{
    print "@dirlist[$i]\n";

}
