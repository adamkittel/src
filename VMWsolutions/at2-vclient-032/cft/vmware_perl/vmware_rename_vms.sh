#!/bin/bash

# This script will rename VMware virtual machines so their hostnames match their VM names
# Uses sqd/solidfire as the credentials for your cluster - to use different credentials, export SFUSERNAME and SFPASSWORD env variables

# Configuration ----------------------------------------------------

: ${SFEMAIL_NOTIFY:=first.last@solidfire.com}   # Email to notify if there is a failure
: ${SFMGMT_SERVER:=0.0.0.0}                     # IP address of the vSphere server
: ${VM_REGEX:=sqd}                              # Regex to match VMs to rename
: ${CONCURRENT_OPS:=20}                         # Number of rename jobs to start in parallel
# End configuration ------------------------------------------------

source ../libsf.sh
loginfo "============ Getting a list of VMs ============"
VM_LIST=$(perl vmware_list_vm_names.pl --mgmt_server=$SFMGMT_SERVER --vm_regex=$VM_REGEX --bash) || fail "Could not get list of VMs"
declare -a RENAME_JOBS=()
for VM_NAME in ${VM_LIST[@]}; do
    VM_IP=$(perl vmware_get_vm_ip.pl --mgmt_server=$SFMGMT_SERVER --vm_name=$VM_NAME --bash) || fail "Could not get IP of VM"
    python ../set_client_hostname.py --client_ip=$VM_IP --hostname=$VM_NAME &
    PID=$!
    RENAME_JOBS[${#RENAME_JOBS[*]}]="$PID"
    
    if [[ "${#RENAME_JOBS[@]}" -ge "$CONCURRENT_OPS" ]]; then
        loginfo "============ Waiting for rename jobs to complete ============"
        FAIL=0
        for PID in ${RENAME_JOBS[@]}; do
            wait $PID || FAIL=1
        done

        if [[ "$FAIL" -ne "0" ]]; then
            fail "Renaming failed"
        fi
        
        declare -a RENAME_JOBS=()
    fi
    
done

