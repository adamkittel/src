# This test will bounce the network on the nodes in the cluster one at a time
# Uses admin/solidfire as the credentials for your cluster - to use different credentials, set SFUSERNAME and SFPASSWORD env variables

# Configuration ----------------------------------------------------

: ${SFMVIP:=0.0.0.0}                            # Management VIP of the cluster
: ${SFEMAIL_NOTIFY:=first.last@solidfire.com}   # Email to notify if there is a failure
: ${WAIT_TIME:=300}                             # How many seconds to wait between each iteration (after the cluster is healthy)
: ${ITERATIONS:=0}                              # How many iterations - 0 means run forever
: ${INTERFACE_NAME:=Bond10G}                    # The name of the network interface to bounce
: ${SFCLIENT_IPS:=}                             # List of IP addreses of the clients


# Special case if you want to bounce all but one node, set this to a valid IP
: ${SKIP_NODE:=0.0.0.0}                         # Management IP address of a node to skip

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
while true; do

    logbanner "Iteration $ITERATION"

    # Reboot each node in the list
    CURRENT_NODE=1
    for NODE_IP in ${NODE_LIST[@]}; do

        if [ "$NODE_IP" == "$SKIP_NODE" ]; then
            loginfo "============ Skipping $SKIP_NODE ============"
            CURRENT_NODE=$(($CURRENT_NODE+1))
            continue
        fi

        # Display and log who is the cluster master
        python get_cluster_master.py --mvip=$SFMVIP

        # Take the network down and then up on the node
        loginfo "============ Bouncing $INTERFACE_NAME network on $NODE_IP ($CURRENT_NODE / $NODE_COUNT) ============"
        ssh root@$NODE_IP "ifconfig $INTERFACE_NAME down; sleep 20; ifconfig $INTERFACE_NAME up" || fail "Failed bouncing network on node"

        # Wait some time to make sure the fault monitor picks up new faults
        sleep 60

        # Wait for faults to clear
        loginfo "============ Waiting for cluster faults to clear ============"
        python wait_for_no_faults.py --mvip=$SFMVIP  || fail "Failed waiting for cluster faults"

        # Make sure the cluster is healthy
        loginfo "============ Checking cluster health ============"
        python check_cluster_health.py --mvip=$SFMVIP --since=$START_TIME || fail "Failed cluster health check"

        # Check the health of the clients
        if [ ! -z "$SFCLIENT_IPS" ]; then
            loginfo "============ Checking client health ============"
            python check_client_health.py --client_ips=$SFCLIENT_IPS || fail "Failed client health check"
        fi

        # See if there are available drives because the node took too long to recover
        loginfo "============ Checking for available drives ============"
        python count_available_drives.py --mvip=$SFMVIP --expected=0 || {
            # Notify the user about this but continue the test anyway
            logerror "============ Found available drives - $NODE_IP probably took too long to reboot ============"
            python send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject "Node $NODE_IP took too long to reboot"

            # Add the drives back to the cluster
            loginfo "============ Adding available drives back to cluster ============"
            python add_available_drives.py --mvip=$SFMVIP || fail "Failed adding drives"

            # Check the health of the clients
            if [ ! -z "$SFCLIENT_IPS" ]; then
                loginfo "============ Checking client health ============"
                python check_client_health.py --client_ips=$SFCLIENT_IPS || fail "Failed client health check"
            fi
        }

        # Wait a little while before the next node
        if [ "$WAIT_TIME" -gt "0" ]; then loginfo "============ Waiting for $WAIT_TIME seconds ============"; sleep $WAIT_TIME; fi

        CURRENT_NODE=$(($CURRENT_NODE+1))
    done

    # Update the iteration cound and exit if we are done
    ITERATION=$(($ITERATION+1))
    if [[ "$ITERATIONS" -gt "0" && "$ITERATION" -gt "$ITERATIONS" ]]; then exit 0; fi

    # Run GC after every full iteration through the cluster to prevent it from filling
    loginfo "============ Running GC on the cluster ============"
    GC_START=`date +%s`
    sleep 3
    python start_gc.py --mvip=$SFMVIP || fail "Failed starting GC"
    python wait_for_gc.py --mvip=$SFMVIP --since=$GC_START || fail "Failed waiting for GC"

done

# Send an email to tell the user the test is finished
python send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject="Finished `basename $0`"
exit 0
