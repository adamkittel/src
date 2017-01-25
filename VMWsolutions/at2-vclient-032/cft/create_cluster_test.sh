# Configuration ----------------------------------------------------

MVIP=192.168.154.2
SVIP=10.10.19.2
CLUSTER_NAME=createtest
NODE_IPS=192.168.133.12,192.168.133.20,192.168.133.68,192.168.133.93,192.168.133.96,192.168.133.76,192.168.133.113,192.168.133.114
NOTIFY=carl.seelye@solidfire.com

# End configuration ------------------------------------------------


# Make sure we can SSH to everybody
python push_ssh_keys_to_node.py --node_ips=$NODE_IPS

# Make the list of IPs into a bash friendly array
IFS=',' read -a NODE_LIST <<< "$NODE_IPS"
# Determine how many nodes we have to use
NODE_COUNT=${#NODE_LIST[@]}
if [ "$NODE_COUNT" -lt "3" ]; then
    echo "You must have 3 or more nodes"
    exit 1
fi

# Build clusters of 3 - N nodes
for (( c=3; c<=$NODE_COUNT; c++ )); do

    # Make a list of the nodes to use for this iteration
    CLUSTER_NODES=(${NODE_LIST[@]:0:$c})
    NON_CLUSTER_NODES=(${NODE_LIST[@]:$(($c)):$(($NODE_COUNT-$c))})
    CLUSTER_SIZE=${#CLUSTER_NODES[@]}

    echo "============ Setting cluster name to $CLUSTER_NAME ============="
    for NODE in ${CLUSTER_NODES[@]}; do
        # Set solidfire.json to this cluster name
        python set_json_clustername.py --node_ips=$NODE --cluster_name=$CLUSTER_NAME || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed setting clustername"; exit 1; }
    done

    echo "============ Setting cluster name to NON-$CLUSTER_NAME ============="
    for NODE in ${NON_CLUSTER_NODES[@]}; do
        # Set solidfire.json to a different cluster name
        python set_json_clustername.py --node_ips=$NODE --cluster_name=NOT-${CLUSTER_NAME} || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed setting clustername"; exit 1; }
    done

    # Create the cluster
    echo "============ Creating a $CLUSTER_SIZE node cluster with $CLUSTER_NODES ============="
    python create_cluster.py --mvip=$MVIP --svip=$SVIP --node_ip=${CLUSTER_NODES[0]} --node_count=$c || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating cluster"; exit 1; }

    # Check that we have the correct number of ensemble nodes
    echo "============ Checking ensemble membership ============"
    python check_ensemble_size.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed ensemble size check"; exit 1; }

    # Sanity check - create an account and some volumes
    echo "============ Creating an account and volumes ============="
    python create_account.py --mvip=$MVIP --account_name=testaccount || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating account"; exit 1; }
    python create_volumes.py --mvip=$MVIP --volume_prefix=testvol --volume_count=20 --volume_size=100 --512e --account_name=testaccount || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating volumes"; exit 1; }

    echo
    echo "======================================================="
    echo "============ PASS with $CLUSTER_SIZE nodes ============"
    echo "======================================================="
    echo

    # Destroy the cluster and reset all of the nodes
    echo "============ Resetting all nodes ============="
    python cluster_sfnodereset.py --node_ips=$NODE_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed resetting nodes"; exit 1; }

done

python send_email.py --email_to $notify --email_subject="Successfully finished `basename $0`"
exit 0
