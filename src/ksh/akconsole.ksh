#!/bin/ksh

infile=/home/oper/bin/.hosts.list
#infile=./hosts.list

hosts=`cat $infile | grep -v "#"`
TIME=`date | awk '{print $2,$3}'`
#xterm -sl 5000 -fn 7x13 -geometry 150x30 -fg cyan -bg grey30 -e tail -f /home/akittel/text/messages &

for SYS in $hosts
do
  SYS_SIZE=`rsh -l oper $SYS ls -l /var/adm/messages | awk '{print $5}'`
  print $SYS_SIZE
done
