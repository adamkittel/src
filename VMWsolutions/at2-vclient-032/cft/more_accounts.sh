# Simple example of creating accounts on a cluster
# See also more_volumes.sh
MVIP=192.168.154.1
START=1
END=100
PREFIX=zztestaccount


i=$START
while [ "$i" -le "$END" ]; do
	ACCOUNT_NAME=${PREFIX}${i}
	python create_account.py --mvip=$MVIP --account_name=$ACCOUNT_NAME
	i=$[$i + 1]
done

