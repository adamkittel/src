MVIP=192.168.154.1
USERNAME=admin
PASSWORD=solidfire

while true; do
	echo "`date`   Checking ${MVIP}..."
	ping -c3 -i0.2 -q -W0.5 ${MVIP} > /dev/null
	STATUS=$?
	if [ "$STATUS" -eq "0" ]; then 
		echo "`date`   MVIP is responding to ping"
	else 
		echo "`date`   * * * * * * * * * * * * MVIP is not responding to ping"
		sleep 1
		continue
	fi

	wget -q --no-check-certificate -O /dev/null https://${USERNAME}:${PASSWORD}@${MVIP}/json-rpc/1.0?method=GetClusterInfo
	STATUS=$?
	if [ "$STATUS" -eq "0" ]; then
		echo "`date`   MVIP is responding to API calls"
	else
		echo "`date`   * * * * * * * * * * * * MVIP is not responding to API calls"
	fi
	
	sleep 1
done
