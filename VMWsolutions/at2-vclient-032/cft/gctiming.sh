# Usage/Prerequisites
#  Create a cluster with no volumes, no used space
#  Disable GC on the cluster (set -gcinterval to 300000 or so in /etc/default/solidfire and restart solidfire)
#  Set up passwordless SSH between the vdbench master and client
#  Make sure all of the required python scripts are present (lab repo under scripts directory), in your PATH, and chmod'd executable
#  Make sure all of the required python modules are installed (paramiko, colorconsole)
#  Run this script on the vdbench master

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# Configuration

MVIP=192.168.154.2
SVIP=10.10.19.2
CLIENT_IP=192.168.140.137
VOLUME_COUNT=50
#FILL_INCREMENT=1000  # in GB
FILL_LEVELS=( 24000 ) # in GB
NOTIFY_EMAIL=carl.seelye@solidfire.com
OUTPUT_FILE=gctime.csv

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #



echo "VolumeCount,ProvisionedSpace,UsedSpace,GCDuration" >> $OUTPUT_FILE

# Total space on the cluster
echo ">> Getting cluster capacity stats <<"
CLUSTER_SIZE=$(get_cluster_capacity.py --mvip=$MVIP --stat=maxUsedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting usable space"; exit 1; }
MAX_PROVISIONED=$(get_cluster_capacity.py --mvip=$MVIP --stat=maxProvisionedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting usable space"; exit 1; }

# Starting used space on the cluster
CLUSTER_BASE_USED=$(get_cluster_capacity.py --mvip=$MVIP --stat=usedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting usable space"; exit 1; }

# Get the volume size needed to fill the cluster
VOLUME_SIZE=$(echo "$CLUSTER_SIZE / $VOLUME_COUNT" / 2 | bc)

printf "    Cluster size = %'.3d B\n" $CLUSTER_SIZE
printf "    Currently used = %'.3d B\n" $CLUSTER_BASE_USED
printf "    Provisionable space = %'.3d B\n" $MAX_PROVISIONED
printf "    Volume count = $VOLUME_COUNT\n"
printf "    Volume size = %'.3d B\n" $VOLUME_SIZE

#echo  ">> Cleaning and configuring client <<"
# Get the client hostname
HOSTNAME=$(get_hostname.py --client_ip=$CLIENT_IP)  || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting client hostname"; exit 1; }

# Clean up any previous volumes on client
logout_iscsi.py --client_ips=$CLIENT_IP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed logging out client volumes"; exit 1; }
clean_iscsi.py --client_ips=$CLIENT_IP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed cleaning iscsi"; exit 1; }
reboot_soft.py --client_ips=$CLIENT_IP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed rebooting client"; exit 1; }
enable_interfaces.py --client_ips=$CLIENT_IP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed enabling interfaces"; exit 1; }

# Setup account on cluster and CHAP on client
setup_chap.py --client_ips=$CLIENT_IP --mvip=$MVIP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed setting up account/CHAP"; exit 1; }

# Creat an extra account
create_account.py --mvip=$MVIP --account_name=gctest

# Create the volumes
echo ">> Creating volumes <<"
create_volumes.py --mvip=$MVIP --volume_size=$((VOLUME_SIZE/1000/1000/1000)) --volume_count=$VOLUME_COUNT --volume_prefix=fill --account_name=$HOSTNAME || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed creating volumes"; exit 1; }

# Log in to the volumes
echo ">> Logging in to volumes <<"
login_iscsi.py --client_ips=$CLIENT_IP --svip=$SVIP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed logging in to volumes"; exit 1; }
count_drives.py --client_ips=$CLIENT_IP --expected=$VOLUME_COUNT || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed client volume count"; exit 1; }

# Provisioned space on the cluster
echo ">> Wait a little while for cluster stats to update <<"
sleep 90
CLUSTER_PROVISIONED=$(get_cluster_capacity.py --mvip=$MVIP --stat=provisionedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting provisioned space"; exit 1; }

VOLUME_RANGE_START=0
VOLUME_RANGE_END=0
#FILL_LEVEL=$FILL_INCREMENT
#while [ "$FILL_LEVEL" -le "$CLUSTER_SIZE" ]; do
CLUSTER_CURRENT_USED=0
for FILL_LEVEL in $FILL_LEVELS; do
    CLUSTER_CURRENT_USED=$(get_cluster_capacity.py --mvip=$MVIP --stat=usedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting used space"; exit 1; }
    FILL_LEVEL=$(echo "$FILL_LEVEL* 1000^3" | bc)
    VOLUME_FILL_INCREMENT=$(echo "($FILL_LEVEL - $CLUSTER_CURRENT_USED) / $VOLUME_COUNT / 2" | bc)

    printf ">> Filling cluster to %'.3d B << \n" $FILL_LEVEL
    if [ "$VOLUME_RANGE_END" -le "0" ]; then
        VOLUME_RANGE_START=0
        VOLUME_RANGE_END=$(echo "$VOLUME_FILL_INCREMENT - ($CLUSTER_BASE_USED / $VOLUME_COUNT / 2)" | bc)
    else
        VOLUME_RANGE_START=$(echo "$FILL_LEVEL / $VOLUME_COUNT / 2 - $VOLUME_FILL_INCREMENT" | bc)
        VOLUME_RANGE_END=$(echo "$VOLUME_RANGE_START + $VOLUME_FILL_INCREMENT" | bc)
    fi
    printf ">> Filling volumes from %'.3d B to %'.3d B << \n" $VOLUME_RANGE_START $VOLUME_RANGE_END
    if [ "$VOLUME_RANGE_END" -le "0" ]; then
        echo "Error calculating range - end is negative"
        exit 1
    elif [ "$VOLUME_RANGE_END" -le "$VOLUME_RANGE_START" ]; then
        echo "Error calculating range - end is less than start"
        exit 1
    elif [ "$VOLUME_RANGE_END" -eq "$VOLUME_RANGE_START" ]; then
        echo "Error calculating range - end is qual to start"
        exit 1
    fi

    # Make vdbench input files for fill and for 80/20 4k
    #create_vdbench_input.py --client_ips=$CLIENT_IP --workload="rdpct=80,seekpct=random,range=(${VOLUME_RANGE_START},${VOLUME_RANGE_END}),xfersize=4k" --threads=4 --compratio=1 --dedupratio=1 --nodatavalidation || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed creating vdbench workload"; exit 1; }
    #mv vdbench_input vdbench_8020
    create_vdbench_input.py --client_ips=$CLIENT_IP --workload="rdpct=0,seekpct=eof,range=(${VOLUME_RANGE_START},${VOLUME_RANGE_END}),xfersize=256k" --threads=1 --compratio=1 --dedupratio=1 --nodatavalidation || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed creating fill workload"; exit 1; }
    mv vdbench_input vdbench_fill

    # Fill the volumes
    vdbench -o /var/log/testlogs/vdbench.fill.tod -f vdbench_fill || {
        FULL=$(echo "$CLUSTER_SIZE * 0.93" | bc)
        if [ "$FILL_LEVEL" -lt "$FULL" ]; then
            echo ">> Aborting script <<"
            send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed running vdbench"
            exit 1
        fi
    }

    # Wait to make sure cluster capacity stats get updated
    echo ">> Waiting a little while to make sure cluster stats are up to date <<"
    sleep 60
    CLUSTER_CURRENT_USED=$(get_cluster_capacity.py --mvip=$MVIP --stat=usedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting used space"; exit 1; }

    # Start IO workload
    #echo ">> Starting vdbench workload <<"
    #vdbench -o /var/log/testlogs/vdbench.tod -f vdbench_8020 2>&1 > vdbench_stdout &
    #VDBENCH_SCRIPT_PID=$!

    # Start GC
    echo ">> Resetting timing report <<"
    reset_timing_report.py --mvip=$MVIP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed resetting report"; exit 1; }
    echo ">> Starting GC <<"
    GC_TIME=`date +%s`
    sleep 2
    start_gc.py --mvip=$MVIP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed starting GC"; exit 1; }
    wait_for_gc.py --mvip=$MVIP --since=$GC_TIME || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed waiting for GC"; exit 1; }
    GC_DURATION=$(get_last_gc_duration.py --mvip=$MVIP) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting last GC duration"; exit 1; }

    echo ">> Writing result to $OUTPUT_FILE <<"
    echo "$VOLUME_COUNT,$CLUSTER_PROVISIONED, $CLUSTER_CURRENT_USED, $GC_DURATION" >> $OUTPUT_FILE

    echo ">> Saving reports <<"
    save_reports.py --mvip=$MVIP --interval=-1 --reports=timing --label="gc_$((CURRENT_PROVISIONED/1000/1000/1000))gb_$((FILL_LEVEL/1000/1000/1000))gb" || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed saving reports"; exit 1; }

    if [ "$GC_DURATION" -ge "3600" ]; then
	exit 0
    fi

    # Use clones to step up through provisioned space
    CURRENT_PROVISIONED=$(get_cluster_capacity.py --mvip=$MVIP --stat=provisionedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting provisioned space"; exit 1; }
    CLONE_SPACE=$(echo "$MAX_PROVISIONED - $CURRENT_PROVISIONED - 10*1000^4" | bc)
    PROVISION_LIMIT=$(echo "$MAX_PROVISIONED - 8*1000^4" | bc)
    CLONE_SIZE=0
    CLONE_COUNT=0
    while [ "$CURRENT_PROVISIONED" -lt "$PROVISION_LIMIT" ]; do
        CLONE_SIZE=8000000000000
        if [ "$CLONE_SIZE" -gt "$CLONE_SPACE" ]; then
            CLONE_SIZE=$CLONE_SPACE
        fi
        printf ">> Increasing provisioned space by %'.3d B <<\n" $CLONE_SIZE
        clone_volume.py --mvip=$MVIP --volume_name=fill00001 --clone_count=1 --clone_prefix="-c" --account_name=gctest --clone_size=$CLONE_SIZE || break #{ echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed cloning volume"; exit 1; }
	VOLUME_SIZE=$(echo "$CLONE_SIZE / 1000 / 1000 / 1000" | bc)
#	create_volumes.py --mvip=$MVIP --volume_prefix=fill2- --volume_count=1 --volume_size=$VOLUME_SIZE --account_name=gctest || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting provisioned space"; exit 1; }

        echo ">> Waiting a little while to make sure cluster stats are up to date <<"
        sleep 60
        CURRENT_PROVISIONED=$(get_cluster_capacity.py --mvip=$MVIP --stat=provisionedSpace) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting provisioned space"; exit 1; }
        CLONE_SPACE=$(echo "$MAX_PROVISIONED - $CURRENT_PROVISIONED - 10*1000^4" | bc)
        CLONE_COUNT=$((CLONE_COUNT + 1))

        # Start GC
        echo ">> Resetting timing report <<"
        reset_timing_report.py --mvip=$MVIP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed resetting report"; exit 1; }
        echo ">> Starting GC <<"
        GC_TIME=`date +%s`
        sleep 2
        start_gc.py --mvip=$MVIP || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed starting GC"; exit 1; }
        wait_for_gc.py --mvip=$MVIP --since=$GC_TIME || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed waiting for GC"; exit 1; }
        GC_DURATION=$(get_last_gc_duration.py --mvip=$MVIP) || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed getting last GC duration"; exit 1; }

        echo ">> Writing result to $OUTPUT_FILE <<"
        echo "$((VOLUME_COUNT + CLONE_COUNT)),$CURRENT_PROVISIONED, $CLUSTER_CURRENT_USED, $GC_DURATION" >> $OUTPUT_FILE

        echo ">> Saving reports <<"
        save_reports.py --mvip=$MVIP --interval=-1 --reports=timing --label="gc_$((CURRENT_PROVISIONED/1000/1000/1000))gb_$((FILL_LEVEL/1000/1000/1000))gb" || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed saving reports"; exit 1; }
        if [ "$GC_DURATION" -ge "3600" ]; then
	    exit 0
        fi
    done

    # Stop IO workload
    #echo ">> Stopping vdbench workload <<"
    #kill -2 `ps -C java -o pid,ppid,args | grep Vdbmain | grep $VDBENCH_SCRIPT_PID | awk '{print $1}'`
    #wait $VDBENCH_SCRIPT_PID
    #echo "                                                     "
    #sleep 60

    # Delete clones
    echo ">> Deleting clones <<"
    delete_volumes.py --mvip=$MVIP --account_name=gctest || { echo ">> Aborting script <<"; send_email.py --email_to $NOTIFY_EMAIL --email_subject "Failed deleting clones"; exit 1; }

    #FILL_LEVEL=$[$FILL_LEVEL + $FILL_INCREMENT]

done
