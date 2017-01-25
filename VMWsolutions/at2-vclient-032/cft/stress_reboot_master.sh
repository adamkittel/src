# This test will reboot the nodes in the cluster one at a time
# Uses admin/solidfire as the credentials for your cluster - to use different credentials, set SFUSERNAME and SFPASSWORD env variables

# Configuration ----------------------------------------------------

: ${SFMVIP:=0.0.0.0}                            # Management VIP of the cluster
: ${SFEMAIL_NOTIFY:=first.last@solidfire.com}   # Email to notify if there is a failure
: ${WAIT_TIME:=300}                             # How many seconds to wait between each iteration (after the cluster is healthy)
: ${ITERATIONS:=0}                              # How many iterations - 0 means run forever
: ${SFCLIENT_IPS:=}                             # List of IP addreses of the clients

# End configuration ------------------------------------------------

source libsf.sh

# Get the list of nodes in the cluster
loginfo "============ Getting a list of nodes in the cluster ============="
NODE_IPS=`python get_active_nodes.py --mvip=$SFMVIP --csv` || fail "Failed getting list of nodes"

# Make sure we can SSH to all nodes
# Only need to run this once, not every run of this script
loginfo "============ Setting up SSH keys on nodes ============="
python push_ssh_keys_to_node.py --node_ips=$NODE_IPS  || fail "Failed pushing SSH keys"

# Make the list of IPs into a bash friendly array
IFS=',' read -a NODE_LIST <<< "$NODE_IPS"
NODE_COUNT=${#NODE_LIST[@]}

# Record what time we are starting the test
START_TIME=`date +%s`
ITERATION=1
while [ 1 ]; do

    logbanner "Iteration $ITERATION"

    # Find the cluster master node
    loginfo "============ Finding the cluster master ============"
    NODE_IP=`python get_cluster_master.py --mvip=$SFMVIP --csv` || fail "Failed getting the cluster master"

    # Reboot the node
    loginfo "============ Rebooting $NODE_IP ============"
    python reboot_node.py --node_ip=$NODE_IP || fail "Failed rebooting node"

    # Wait for faults to clear
    loginfo "============ Waiting for cluster faults to clear ============"
    python wait_for_no_faults.py --mvip=$SFMVIP  || fail "Failed waiting for cluster faults"

    # Make sure the cluster is still healthy
    loginfo "============ Checking cluster health ============"
    python check_cluster_health.py --mvip=$SFMVIP --since=$START_TIME || fail "Failed cluster health check"

    # Check the health of the clients
    if [ ! -z "$SFCLIENT_IPS" ]; then
        loginfo "============ Checking client health ============"
        python check_client_health.py --client_ips=$SFCLIENT_IPS || fail "Failed client health check"
    fi

    # See if there are available drives because the node took too long to reboot
    loginfo "============ Checking for available drives ============"
    python count_available_drives.py --mvip=$SFMVIP --expected=0 || {
        # Notify the user about this but continue the test anyway
        logerror "============ Found available drives - $NODE_IP probably took too long to reboot ============"
        python send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject "Node $NODE_IP took too long to reboot"

        # Add the drives back to the cluster and wait for sync
        loginfo "============ Adding available drives back to cluster ============"
        python add_available_drives.py --mvip=$SFMVIP || fail "Failed adding drives"

        # Check the health of the clients
        if [ ! -z "$SFCLIENT_IPS" ]; then
            loginfo "============ Checking client health ============"
            python check_client_health.py --client_ips=$SFCLIENT_IPS || fail "Failed client health check"
        fi
    }

    # Update the iteration cound and exit if we are done
    ITERATION=$(($ITERATION+1))
    if [[ "$ITERATIONS" -gt "0" && "$ITERATION" -gt "$ITERATIONS" ]]; then exit 0; fi

    # Wait a little while before the next node
    if [ "$WAIT_TIME" -gt "0" ]; then loginfo "============ Waiting for $WAIT_TIME seconds ============"; sleep $WAIT_TIME; fi

    # Run GC every once in a while to keep the cluster from filling
    TEST=$(($ITERATION % $NODE_COUNT))
    if [ "$TEST" -eq "0" ]; then
        loginfo "============ Running GC on the cluster ============"
        GC_START=`date +%s`
        sleep 3
        python start_gc.py --mvip=$SFMVIP || fail "Failed starting GC"
        python wait_for_gc.py --mvip=$SFMVIP --since=$GC_START || fail "Failed waiting for GC"
    fi

done

# Send an email to tell the user the test is finished
python send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject="Finished `basename $0`"
exit 0
