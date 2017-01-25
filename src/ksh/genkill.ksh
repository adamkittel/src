#!/bin/ksh
# kills all the processes of a certain group
# usage genkill.ksh [process search type]

integer PID

#ps -eaf | grep $1 | awk '{print $2}' > gentmp

while read PID
do 
	kill $PID
done
