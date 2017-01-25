#!/bin/ksh

infile=/home/oper/bin/.hosts.list
export TODAY=`date | awk '{print $2,$3}'`
hosts=`cat $infile | grep -v "#"`

for SYS in $hosts
do
  rsh -l oper $SYS "tail -3 /var/adm/messages" >> /home/akittel/text/messages
done
 mailx -s Messages kittel.adam < /home/akittel/text/messages
