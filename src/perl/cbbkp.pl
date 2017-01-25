#!/usr/bin/perl

$date = `date`;
@date1 = split(' ',$date);

system("cp /export/home/akittel/.cbb /backup/cbb.$date1[0]-$date1[1]-$date1[2]-$date1[5]");
