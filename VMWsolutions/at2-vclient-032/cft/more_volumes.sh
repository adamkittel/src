# Simple example of creating volumes to increase the volume count and provisioning of a cluster
# See also more_accounts.sh
MVIP=192.168.154.1
STARTACCOUNT=1
ENDACCOUNT=15
VOLUME_SIZE=100
VOLUME_COUNT=100
ACCOUNT_PREFIX=zztestaccount


i=$STARTACCOUNT
while [ "$i" -le "$ENDACCOUNT" ]; do
	ACCOUNT_NAME=${ACCOUNT_PREFIX}${i}
	python create_volumes.py --mvip=$MVIP --volume_size=$VOLUME_SIZE --volume_prefix=${ACCOUNT_NAME}- --volume_count=$VOLUME_COUNT --account_name=$ACCOUNT_NAME&
	i=$(($i+1))
done

