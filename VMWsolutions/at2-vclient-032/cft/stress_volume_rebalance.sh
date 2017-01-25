# This test will create and delete large capacity/high IOPS volumes to cause rebalancing
# Uses admin/solidfire as the credentials for your cluster - to use different credentials, set SFUSERNAME and SFPASSWORD env variables

# Configuration ----------------------------------------------------

: ${SFMVIP:=0.0.0.0}                            # Management VIP of the cluster
: ${SFEMAIL_NOTIFY:=first.last@solidfire.com}   # Email to notify if there is a failure
: ${WAIT_TIME:=300}                             # How many seconds to wait between each iteration
: ${ITERATIONS:=0}                              # How many iterations - 0 means run forever
: ${VOLUME_SIZE:=4000}                          # How large to make the volumes (GB)
: ${VOLUME_IOPS:=15000}                         # minIOPS to set on the new volumes
: ${ACCOUNT_NAME:=rebalancer}                   # Account to use to create the volumes
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

loginfo "============ Creating a test account for the volumes ============="
python create_account.py --mvip=$SFSFMVIP --account_name=$ACCOUNT_NAME || fail "Failed creating account"

# Record what time we are starting the test
START_TIME=`date +%s`
ITERATION=1
while true; do

    logbanner "Iteration $ITERATION"

    # Get a count of how many slice services are in the cluster
    SLICE_COUNT=`python list_slice_services.py --mvip=$SFMVIP --bash | wc -w` || fail "Failed listing services"
    loginfo "There are $SLICE_COUNT slice services in the cluster"

    # Determine how many volumes to create based on the number of slice services
    VOLUME_COUNT=$(($SLICE_COUNT / 3))
    if [ "$VOLUME_COUNT" -lt "1" ]; then
        VOLUME_COUNT=1
    fi

    # Create the volumes
    loginfo "============ Creating $VOLUME_COUNT volumes of size $VOLUME_SIZE GB with $VOLUME_IOPS minIOPS ============="
    python create_volumes.py --mvip=$MVIP --account_name=$ACCOUNT_NAME --volume_prefix=huge --volume_count=$VOLUME_COUNT --volume_size=$VOLUME_SIZE --min_iop=$VOLUME_IOPS --max_iops=100000 --burst_iops=100000 || fail "Failed creating volumes"

    # Wait for a couple of rebalance intervals
    loginfo "============ Waiting 30 minutes for rebalancing ============="
    sleep 1800

    # Make sure the cluster is healthy
    loginfo "============ Checking cluster health ============"
    python check_cluster_health.py --mvip=$SFMVIP --since=$START_TIME || fail "Failed cluster health check"

    # Check the health of the clients
    if [ ! -z "$SFCLIENT_IPS" ]; then
        loginfo "============ Checking client health ============"
        python check_client_health.py --client_ips=$SFCLIENT_IPS || fail "Failed client health check"
    fi

    # Delete the volumes we created
    loginfo "============ Deleting volumes ============="
    python delete_volumes.py --mvip=$SFMVIP --source_account=$ACCOUNT_NAME --volume_prefix=huge --purge || fail "Failed deleting volumes"

    # Wait for a couple of rebalance intervals
    loginfo "============ Waiting 30 minutes for rebalancing ============="
    sleep 1800

    # Make sure the cluster is healthy
    loginfo "============ Checking cluster health ============"
    python check_cluster_health.py --mvip=$SFMVIP --since=$START_TIME || fail "Failed cluster health check"

    # Check the health of the clients
    if [ ! -z "$SFCLIENT_IPS" ]; then
        loginfo "============ Checking client health ============"
        python check_client_health.py --client_ips=$SFCLIENT_IPS || fail "Failed client health check"
    fi

    # Update the iteration count and exit if we are done
    ITERATION=$(($ITERATION+1))
    if [[ "$ITERATIONS" -gt "0" && "$ITERATION" -gt "$ITERATIONS" ]]; then exit 0; fi

    # Refresh the count of slice services
    SLICE_COUNT=`python list_slice_services.py --mvip=$SFMVIP --bash | wc -w` || fail "Failed listing services"

    # Wait a little while before starting again
    loginfo "============ Waiting $WAIT_TIME seconds before the next iteration ============="
    sleep $WAIT_TIME

done

# Send an email to tell the user the test is finished
python send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject="Finished `basename $0`"
exit 0
