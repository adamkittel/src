#!/bin/bash

clientips="192.168.000.102,192.168.000.103,192.168.000.104,192.168.000.105,192.168.000.106"
altips="10.10.000.102,10.10.000.103,10.10.000.104,10.10.000.105,10.10.000.106"
mvip="192.168.000.1"
svip="10.10.000.1"
firstnode="192.168.133.0"
notify="your.name@solidfire.com"
volumefile=volumes.txt
volumecount=75
volumesize=3
workload="rdpct=80,seekpct=random,xfersize=4k"


echo ">> Creating cluster <<"
python create_cluster.py --mvip $mvip --svip $svip --node_ip $firstnode || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed creating cluster"; exit 1; }
#python create_cluster.py --mvip $mvip --svip $svip --node_ip $firstnode --drive_count 30 || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed creating cluster"; exit 1; }

echo ">>> Reboot clients <<<"
python reboot_soft.py --client_ips $clientips --alt_ips $altips || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed rebooting clients"; exit 1; }
# On linux VMs sometimes the network interfaces fail to come up - this makes sure they are all up and ready
python enable_interfaces.py --client_ips $clientips || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed enabling interfaces"; exit 1; }

echo ">>> Setup accounts for clients <<<"
python create_account_for_client.py --mvip=$mvip --svip=$svip --client_ips=$clientips || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed setting up accounts"; exit 1; }

echo ">>> Create volumes <<<"
python create_volumes_for_client.py --mvip=$mvip --volume_size=$volumesize --volume_count=$volumecount --512e --client_ips=$clientips || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed creating volumes"; exit 1; }
python wait_syncing.py --mvip $mvip || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed waiting for syncing"; exit 1; }

echo ">>> Login volumes on clients <<<"
python login_client.py --mvip=$mvip --svip=$svip --expected=$volumecount --client_ips=$clientips || { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed logging in to volumes"; exit 1; }

echo ">>> Saving a list of volumes in $volumefile <<<"
python list_volumes.py --client_ips $clientips > $volumefile

echo ">>> Create vdbench input file <<<"
python create_vdbench_input.py --client_ips $clientips --interval 60 --run_time 24h --workload="$workload" --threads 4 ||  { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "Failed creating vdbench input"; exit 1; }

echo ">>> Starting vdbench <<<"
mkdir /var/log/vdbench
python run_vdbench.py --output_dir /var/log/vdbench/vdbench.tod ||  { echo ">> Aborting script <<"; python send_email.py --email_to $notify --email_subject "vdbench failure"; exit 1; }

python send_email.py --email_to $notify --email_subject "Finished `basename $0`"
exit 0
