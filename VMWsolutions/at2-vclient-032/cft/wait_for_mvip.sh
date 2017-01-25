MVIP=192.168.0.0
USERNAME=admin
PASSWORD=solidfire

date
echo "Waiting to get a good response from $MVIP"
while true; do
	wget --no-check-certificate -O - https://${USERNAME}:${PASSWORD}@${MVIP}/json-rpc/1.0?method=GetClusterInfo && break
	sleep 30
done
echo
echo "$MVIP alive at `date`"

