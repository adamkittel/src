#!/bin/bash

# This script will deploy VMware virtual machines from a single template image
# Uses sqd/solidfire as the credentials for your cluster - to use different credentials, export SFUSERNAME and SFPASSWORD env variables

# Configuration ----------------------------------------------------

: ${SFEMAIL_NOTIFY:=first.last@solidfire.com}   # Email to notify if there is a failure
: ${SFMGMT_SERVER:=0.0.0.0}                     # IP addrese of the vSphere server
: ${DEST_FOLDER:=vm}                            # The folder to put the clones in
: ${SOURCE_VM:=esx-ubuntu-gold}                 # Source VM to clone
: ${CLONE_PREFIX:=esx-sqd-}                     # Prefix for the clone names
: ${CLONE_COUNT:=0}                             # Total number of clones to create
: ${CONCURRENT_OPS:=20}                         # Number of clone jobs to start in parallel
# End configuration ------------------------------------------------

source ../libsf.sh
loginfo "============ Getting a list of hosts ============"
HOST_LIST=$(perl vmware_list_hosts.pl --mgmt_server=$SFMGMT_SERVER --bash)
HOST_INDEX=0

loginfo "============ Looking for existing VMs ============"
VM_COUNT=`perl vmware_count_vms.pl --mgmt_server=$SFMGMT_SERVER --vm_prefix=$CLONE_PREFIX --bash` || fail "Could not get count of VMs"

while [ "$VM_COUNT" -lt "$CLONE_COUNT" ]; do
    # concurrent_ops = min(concurrent_ops, clone_count - vm_count)
    CONCURRENT_OPS=$(($CONCURRENT_OPS<$(($CLONE_COUNT-$VM_COUNT))?$CONCURRENT_OPS:$(($CLONE_COUNT-$VM_COUNT))))
    
    CLONE_NUMBERS=`perl vmware_get_next_vm_number.pl --mgmt_server=$SFMGMT_SERVER --vm_prefix=$CLONE_PREFIX --count=$CONCURRENT_OPS --fill --bash` || fail "Could not get next VM numbers"
    loginfo "Creating clones ${CLONE_NUMBERS[@]}"
    declare -a CLONE_JOBS=()
    for CLONE_NUMBER in ${CLONE_NUMBERS[@]}; do
        CLONE_NAME=$CLONE_PREFIX`printf "%05d" $CLONE_NUMBER`
        loginfo "============ Starting clone $CLONE_NAME ============"
        HOST=${HOST_LIST[HOST_INDEX]}
        perl vmware_clone_vm.pl --mgmt_server=$SFMGMT_SERVER --source_vm=$SOURCE_VM --clone_name=$CLONE_NAME --datastore=$CLONE_NAME --vmhost=$HOST --folder=$DEST_FOLDER &
        PID=$!
        CLONE_JOBS[${#CLONE_JOBS[*]}]="$PID"
        
        HOST_INDEX=$(($HOST_INDEX+1))
        if [[ "$HOST_INDEX" -ge "${#NODE_LIST[@]}" ]]; then
            HOST_INDEX=0
        fi
    done
    
    loginfo "============ Waiting for clone jobs to complete ============"
    FAIL=0
    for PID in ${CLONE_JOBS[@]}; do
        wait $PID || FAIL=1
    done
    
    if [[ "$FAIL" -ne "0" ]]; then
        fail "Cloning failed"
    fi

    VM_COUNT=`perl vmware_count_vms.pl --mgmt_server=$SFMGMT_SERVER --vm_prefix=$CLONE_PREFIX --bash` || fail "Could not get count of VMs"

done

loginfo "============ Finished deployment ============"
consoletitle "Finished deployment"
python ../send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject="Finished `basename $0`"
exit 0
