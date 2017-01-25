#!/usr/bin/perl

for($a=0;$a<=100;$a++)
{
    system("ping -c1 dimensional.com");
    sleep 600;
}
