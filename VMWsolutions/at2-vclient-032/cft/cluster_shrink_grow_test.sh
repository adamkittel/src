# This test will remove the nodes in the cluster one at a time until there are only three,
# and then add then back one at a time

# Configuration ----------------------------------------------------

CLIENT_IPS=192.168.140.0,192.168.140.0
VOLUME_COUNT=20
VOLUME_SIZE=2     # Remember GC won't run during the add/remove, so don't make this too big
MVIP=192.168.1.2
SVIP=10.10.1.2
CLUSTER_NAME=abc-synctest # Cluster names must be unique on the subnet! Make this something no one else will use
NODE_IPS=192.168.133.0,192.168.133.0,192.168.133.0,192.168.133.0,192.168.133.0
NOTIFY=first.last@solidfire.com

# End configuration ------------------------------------------------


# Make the list of IPs into a bash friendly array
IFS=',' read -a NODE_LIST <<< "$NODE_IPS"
# Determine how many nodes we have to use
NODE_COUNT=${#NODE_LIST[@]}
if [ "$NODE_COUNT" -lt "4" ]; then
    echo "You must have 4 or more nodes"
    exit 1
fi
FIRST_NODE=${NODE_LIST[0]}

echo "============ Checking for vdbench ============="
which vdbench || { echo "You must have vdbench installed to run this test"; python send_email.py --email_to=$NOTIFY --email_subject "Missing vdbench"; exit 1; }

# Make sure we can SSH to all nodes and clients
# Only need to run this once, not every run of this script
echo "============ Setting up SSH keys ============="
python push_ssh_keys_to_node.py --node_ips=$NODE_IPS  || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed pushing SSH keys"; exit 1; }
python push_ssh_keys_to_client.py --client_ips=$CLIENT_IPS  || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed pushing SSH keys"; exit 1; }

echo "============ Killing any old vdbench processes ============"
TEST=$(ps -ef | grep -v grep | grep -c java)
if [ $TEST -gt "0" ]; then
    killall java
    sleep 60
fi

# Make sure the client has nothing old on it
echo "============ Cleaning up clients ============="
python logout_client.py --client_ips=$CLIENT_IPS
python reboot_client.py --client_ips=$CLIENT_IPS

# Set the cluster name in the "backup" json file so it is correct after sfnodereset
# Only a problem if the node was originally RTFI to a different cluster
echo "============ Setting cluster name in backup JSON file ============"
python set_json_clustername.py --node_ips=$NODE_IPS --cluster_name=$CLUSTER_NAME --rtfi || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed setting cluster name"; exit 1; }

# Reset all of the nodes
echo "============ Resetting nodes ============="
python cluster_sfnodereset.py --node_ips=$NODE_IPS  || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed sfnodereset"; exit 1; }
sleep 30

# Create the cluster
echo "============ Creating cluster ============="
python create_cluster.py --mvip=$MVIP --svip=$SVIP --node_ip=$FIRST_NODE --node_count=$NODE_COUNT  || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating cluster"; exit 1; }

echo "============ Creating account ============="
python create_account_for_client.py --mvip=$MVIP --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating account"; exit 1; }

echo "============ Creating volumes ============"
python create_volumes_for_client.py --mvip=$MVIP --volume_count=$VOLUME_COUNT --volume_size=$VOLUME_SIZE --512e --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating volumes"; exit 1; }

echo "============ Login to volumes ============"
python login_client.py --mvip=$MVIP --svip=$SVIP --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed logging in to volumes"; exit 1; }

echo "============ Creating vdbench input ============"
python create_vdbench_input.py --filename=vdbench_syncing --data_errors=1 --compratio=1 --dedupratio=1 --threads=16 --run_time=170h --workload="rdpct=0,seekpct=random,xfersize=256k" --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating vdbench input"; exit 1; }

echo "============ Starting vdbench in the background (see vdbench_stdout for output) ============"
vdbench -o vdbench.tod -f vdbench_syncing 2>&1 > vdbench_stdout &
VDBENCH_PID=$!

echo "============ Waiting 30 minutes for volumes to fill ============"
sleep 1800

ITERATION=1
while [ 1 ]; do

    echo
    echo "==========================================================================="
    echo "                ============ Iteration $ITERATION ============"
    echo "==========================================================================="
    echo

    # Remove each of the nodes above 3, one at a time
    for (( c=3; c<$NODE_COUNT; c++ )); do

        python get_cluster_master.py --mvip=$MVIP

        NODE_IP=${NODE_LIST[$c]}
        echo "============ Removing $NODE_IP from the cluster ============="
        python remove_node.py --mvip=$MVIP --node_ip=$NODE_IP --remove_drives || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed removing node"; exit 1; }

        # See if vdbench is still running
        echo "============ Checking if vdbench is still running ============="
        TEST=$(ps -p $VDBENCH_PID | grep -c $VDBENCH_PID)
        if [ $TEST -eq "0" ]; then
            echo "============ vdbench failure ============="
            python send_email.py --email_to=$NOTIFY --email_subject "vdbench failure"
            exit 1
        fi

        # Check that the ensemble looks sane
        echo "============ Checking ensemble ============"
        python check_ensemble_size.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed ensemble check"; exit 1; }

        # This makes the node look brand new when it is added back.  It also works around case 6761, 6760
        #echo "============ Resetting $NODE_IP ============"
        #python cluster_sfnodereset.py --node_ips=$NODE_IP  || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed sfnodereset"; exit 1; }

    done

    echo "============ Waiting a couple minutes ============="
    sleep 120

    # Add back each node
    for (( c=3; c<$NODE_COUNT; c++ )); do

        NODE_IP=${NODE_LIST[$c]}
        echo "============ Waiting for $NODE_IP as an available node ============="
        python wait_for_available_nodes.py --mvip=$MVIP --node_ips=$NODE_IP --timeout=180 || {
                # Let the user know there is a problem
                python send_email.py --email_to=$NOTIFY --email_subject "Timed out waiting for node in pending list"

                echo "============ Trying to recover $NODE_IP by rebooting it ============"
                python reboot_node.py --node_ip=$NODE_IP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed rebooting node"; exit 1; }

                echo "============ Waiting for $NODE_IP as an available node ============="
                python wait_for_available_nodes.py --mvip=$MVIP --node_ips=$NODE_IP --timeout=180 || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed waiting for avail node"; exit 1; }
        }

        echo "============ Adding $NODE_IP to the cluster ============="
        python add_node.py --mvip=$MVIP --node_ip=$NODE_IP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed adding node"; exit 1; }

        echo "============ Waiting a couple minutes ============="
        sleep 120

        echo "============ Adding available drives ============="
        python add_available_drives.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed adding drives"; exit 1; }

        # See if vdbench is still running
        echo "============ Checking if vdbench is still running ============="
        TEST=$(ps -p $VDBENCH_PID | grep -c $VDBENCH_PID)
        if [ $TEST -eq "0" ]; then
            echo "============ vdbench failure ============="
            python send_email.py --email_to=$NOTIFY --email_subject "vdbench failure"
            exit 1
        fi

        # Check that the ensemble looks sane
        echo "============ Checking ensemble ============"
        python check_ensemble_size.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed ensemble check"; exit 1; }

        echo "============ Waiting a couple minutes ============="
        sleep 120

    done

    echo "============ Running GC on the cluster ============="
    START_GC=`date +%s`
    sleep 3
    python start_gc.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to $NOTIFY --email_subject "Failed starting GC"; exit 1; }
    python wait_for_gc.py --mvip=$MVIP --since=$START_GC || { echo ">> Aborting script <<"; python send_email.py --email_to $NOTIFY --email_subject "Failed waiting for GC"; exit 1; }

    ITERATION=$(($ITERATION+1))

done
