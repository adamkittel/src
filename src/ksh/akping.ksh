#!/bin/ksh

infile=/home/oper/bin/.hosts.list

hosts=`cat $infile | grep -v "#"`
rm /home/akittel/text/ping.stats
touch /home/akittel/text/ping.stats
for SYS in $hosts
do
	/usr/sbin/ping $SYS >> /home/akittel/text/ping.stats
done

STATS=`grep -v alive /home/akittel/text/ping.stats`

if [$STATS = NULL]
  print "EVERYTHING IS OK"
else
  print $STATS
fi