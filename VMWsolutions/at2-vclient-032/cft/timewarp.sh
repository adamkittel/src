
NODE_IPS=192.168.133.89,192.168.133.93,192.168.133.94

# Make the list of IPs into a bash friendly array
IFS=',' read -a NODE_LIST <<< "$NODE_IPS"

MVIP=192.168.154.2
WAIT_TIME=20
NOTIFY=carl.seelye@solidfire.com

FIRST=1
ITERATION=1
while [ 1 ]; do
	echo ">> Iteration $ITERATION <<"

        COUNT=5
        while [ "$COUNT" -gt 0 ]; do
            STEP=1
            for NODE in ${NODE_LIST[@]}; do
                echo "Setting time backward $STEP years on $NODE"
                python set_node_time.py --node_ip=$NODE --new_time="-$STEP years" || { echo "Failed to set time"; python send_email.py --email_to=$NOTIFY --email_subject "Failed to set time"; exit 1; }
                STEP=$(($STEP+1))
            done
            
            sleep 2
            
            STEP=2
            for NODE in ${NODE_LIST[@]}; do
                echo "Setting time forward $STEP years on $NODE"
                python set_node_time.py --node_ip=$NODE --new_time="+$STEP years" || { echo "Failed to set time"; python send_email.py --email_to=$NOTIFY --email_subject "Failed to set time"; exit 1; }
                STEP=$(($STEP+1))
            done
            
            sleep 5
            
            COUNT=$(($COUNT-1))
        done

	echo "Waiting for $WAIT_TIME seconds"
	sleep $WAIT_TIME

        echo "Checking ensemble health"
        python check_ensemble_health.py --mvip=$MVIP || { echo "Failed ensemble health check"; python send_email.py --email_to=$NOTIFY --email_subject "Failed ensemble health check"; exit 1; }
        
        echo "Setting time back to the present"
        for NODE in ${NODE_LIST[@]}; do
            python set_node_time.py --node_ip=$NODE --new_time="`date`" || { echo "Failed to set time"; python send_email.py --email_to=$NOTIFY --email_subject "Failed to set time"; exit 1; }
        done
        #FIRST=1

	echo "Waiting for $WAIT_TIME seconds"
	sleep $WAIT_TIME

        echo "Checking ensemble health"
        python check_ensemble_health.py --mvip=$MVIP || { echo "Failed ensemble health check"; python send_email.py --email_to=$NOTIFY --email_subject "Failed ensemble health check"; exit 1; }

	ITERATION=$(($ITERATION+1))
        #echo "Waiting for 10 seconds before trying again"
	#sleep 10
done
