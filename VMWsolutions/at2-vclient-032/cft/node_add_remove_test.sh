# Remove and re-add nodes from the cluster
# This script does not include setting or monitoring up any clients/volumes/IO - it assumes an already running cluster

# Configuration ----------------------------------------------------

MVIP=192.168.1.1
CLUSTER_NAME=abc
NODE_IPS=192.168.133.0,192.168.133.0,192.168.133.0,192.168.133.0,192.168.133.0
DRIVE_COUNT=12 # Drives per node - 11 for 6010 or 12 for 3010
NOTIFY=carl.seelye@solidfire.com

# End configuration ------------------------------------------------


# Make sure we can SSH to all nodes
# Only need to run this once, not every run of this script
#echo "============ Setting up SSH keys ============="
python push_ssh_keys_to_node.py --node_ips=$NODE_IPS  || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed pushing SSH keys"; exit 1; }

# Set the cluster name in the "backup" json file so that it doesn't change after sfnodereset
# Only a problem if the node was originally RTFI to a different cluster
echo "============ Setting cluster name in backup JSON file ============"
python set_json_clustername.py --node_ips=$NODE_IPS --cluster_name=$CLUSTER_NAME --rtfi || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed setting cluster name"; exit 1; }

ITERATION=1
while [ 1 ]; do

    echo
    echo "==========================================================================="
    echo "                ============ Iteration $ITERATION ============"
    echo "==========================================================================="
    echo

    MASTER=`python get_cluster_master.py --mvip=$MVIP`
    echo "============ Current cluster master is $MASTER ============"

    # Pick a random ensemble node to remove
    NODE_IP=`python get_random_node.py --mvip=$MVIP --ensemble --nomaster` || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed selecting node"; exit 1; }

    echo "============ Removing $NODE_IP from the cluster ============="
    python remove_node.py --mvip=$MVIP --node_ip=$NODE_IP --remove_drives || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed removing node"; exit 1; }

    # Make the node look brand new
    echo "============ Resetting $NODE_IP ============"
    python cluster_sfnodereset.py --node_ips=$NODE_IP  || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed sfnodereset"; exit 1; }

    echo "============ Waiting for $NODE_IP as an available node ============="
    python wait_for_available_nodes.py --mvip=$MVIP --node_ips=$NODE_IP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed waiting for avail node"; exit 1; }

    echo "============ Adding $NODE_IP to the cluster ============="
    python add_node.py --mvip=$MVIP --node_ip=$NODE_IP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed adding node"; exit 1; }

    echo "============ Adding available drives ============="
    python wait_for_available_drives.py --mvip=$MVIP --drive_count=$DRIVE_COUNT || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed waiting for available drives"; exit 1; }
    python add_available_drives.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed adding drives"; exit 1; }

    # Run GC every 3rd iteration
    MOD=$(($ITERATION % 3))
    if [ "$MOD" -eq 0 ]; then
        echo "============ Running GC on the cluster ============="
        START_GC=`date +%s`
        sleep 3
        start_gc.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to $NOTIFY --email_subject "Failed starting GC"; exit 1; }
        wait_for_gc.py --mvip=$MVIP --since=$START_GC || { echo ">> Aborting script <<"; python send_email.py --email_to $NOTIFY --email_subject "Failed waiting for GC"; exit 1; }
    else
        echo "============ Waiting a couple minutes ============="
        sleep 120
    fi

    ITERATION=$(($ITERATION+1))

done
