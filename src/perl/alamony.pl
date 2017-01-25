#!/usr/bin/perl

open(SRC,"/tmp/x");
@PAYMENTS=<SRC>;

foreach $payment (@PAYMENTS)
{
    $a=$a+$payment;
    print "$a\n";
}
