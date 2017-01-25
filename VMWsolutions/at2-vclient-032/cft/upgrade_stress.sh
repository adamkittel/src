# This script will create a cluster from scratch, create volumes, start IO, run sfinstall to upgrade to another version, then tear it down again, over and over

# Reset cluster with sfnodereset
# Create cluster/add drives
# Create accounts
# Create volumes for accounts
# Log in to volumes on clients
# Create a vdbench input file
# Start vdbench
# Wait a while for volumes to fill
# Run sfinstall
# Check cluster health after the upgrade

# Configuration ----------------------------------------------------

NODE_IPS="192.168.133.0,192.168.133.0,192.168.133.0"
FIRST_NODE=192.168.133.0
MVIP=192.168.0.0
SVIP=10.10.0.0
CLIENT_IPS=192.168.140.0,192.168.140.0
NOTIFY=first.last@solidfire.com
PACKAGE1=solidfire-san-beryllium-4.000.1
PACKAGE2=solidfire-san-beryllium-4.000.2
# End configuration ------------------------------------------------


# Make sure password-less SSH is enabled everywhere
echo ">> Setting up SSH keys <<"
python push_ssh_keys_to_node.py --node_ips=$NODE_IPS
python push_ssh_keys_to_client.py --client_ips=$CLIENT_IPS

# Make sure vdbench isn't still running in the background
killall java > /dev/null 2>&1

ITERATIONS=1
while true; do
    echo "ITERATION $ITERATIONS"

    echo ">> Logging out of volumes on client <<"
    python logout_client.py --client_ips=$CLIENT_IPS

    echo ">> Resetting nodes <<"
    python cluster_sfnodereset.py --node_ips=$NODE_IPS

    # Make sure nodes are all up and ready and discovered each other
    echo ">> Waiting a minute <<"
    sleep 60

    echo ">> Creating cluster <<"
    python create_cluster.py --mvip=$MVIP --svip=$SVIP --node_ip=$FIRST_NODE || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating cluster"; exit 1; }
    echo ">> Creating account <<"
    python create_account_for_client.py --mvip=$MVIP --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating account"; exit 1; }

    echo ">> Creating volumes <<"
    python create_volumes_for_client.py --mvip=$MVIP --volume_count=10 --volume_size=100 --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating volumes"; exit 1; }

    echo ">> Login to volumes <<"
    python login_client.py --mvip=$MVIP --svip=$SVIP --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed logging in to volumes"; exit 1; }

    echo ">> Creating vdbench input <<"
    python create_vdbench_input.py --filename=vdbench_upgrade --nodatavalidation --compratio=1 --dedupratio=1 --threads=16 --client_ips=$CLIENT_IPS || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed creating vdbench input"; exit 1; }

    echo ">> Starting vdbench in the background (see vdbench_stdout for output)<<"
    vdbench -o vdbench.tod -f vdbench_upgrade 2>&1 > vdbench_stdout &

    echo ">> Waiting 30 minutes for volumes to fill <<"
    sleep 1800

    echo ">> Starting sfinstall <<"
    if [ $(($ITERATIONS % 2)) -eq 0 ]; then
        sfinstall $MVIP -u admin -p solidfire $PACKAGE1 || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed running sfinstall"; exit 1; }
    else
        sfinstall $MVIP -u admin -p solidfire $PACKAGE2 || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed running sfinstall"; exit 1; }
    fi

    echo ">> Stopping vdbench <<"
    killall java
    # Wait a little to make sure all vdbench processes have stopped
    sleep 10

    echo ">> Checking cluster health <<"
    python check_cluster_health.py --mvip=$MVIP || { echo ">> Aborting script <<"; python send_email.py --email_to=$NOTIFY --email_subject "Failed cluster health check"; exit 1; }

    ITERATIONS=$((ITERATIONS+1))
done
