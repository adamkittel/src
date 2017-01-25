
NODES=192.168.133.1,192.168.133.2,192.168.133.3,192.168.133.12,192.168.133.13,192.168.133.14,192.168.133.17,192.168.133.68,192.168.133.72,192.168.133.84,192.168.133.111,192.168.133.112,192.168.133.113,192.168.133.114
IFS=',' read -a NODE_LIST <<< "$NODES"

for NODE in ${NODE_LIST[@]}; do
    STATUS=0
    ping -i 0.2 -f -c 3 $NODE >/dev/null && STATUS=1
    if [ "$STATUS" -eq "1" ]; then
        STATUS=0
        ssh -l root $NODE uptime >/dev/null 2>/dev/null && STATUS=1
    fi

    if [ "$STATUS" -eq "1" ]; then
        echo "$NODE is good"
    else
        echo "Can't contact $NODE"
    fi

done
