#!/bin/bash

# This script will deploy KVM virtual machines from a single gold image
# Uses admin/solidfire as the credentials for your cluster - to use different credentials, export SFUSERNAME and SFPASSWORD env variables

# Configuration ----------------------------------------------------

: ${SFMVIP:=0.0.0.0}                            # Management VIP of the cluster
: ${SFEMAIL_NOTIFY:=first.last@solidfire.com}   # Email to notify if there is a failure
: ${SFVMHOST:=0.0.0.0}                          # IP addrese of the KVM hypervisor
: ${SFHOST_USER:=}                              # Username of the KVM hypervisor
: ${SFHOST_PASS:=}                              # Password of the KVM hypervisor
: ${SOURCE_VM:=}                                # Source VM to clone
: ${CLONE_PREFIX:=kvm-ubuntu-}                  # Prefix for the clone names
: ${CLONE_COUNT:=100}                           # Total number of clones to create

# End configuration ------------------------------------------------

source libsf.sh

loginfo "============ Looking for existing VMs ============"
VM_COUNT=`python kvm_count_vms.py --vmhost=$SFVMHOST --vm_prefix=$CLONE_PREFIX --bash` || fail "Could not get count of VMs"
while [ "$VM_COUNT" -lt "$CLONE_COUNT" ]; do
    CLONE_NUMBER=`python kvm_get_next_vm_number.py --vmhost=$SFVMHOST --vm_prefix=$CLONE_PREFIX --fill --bash` || fail "Could not get next VM number"
    CLONE_NAME=$CLONE_PREFIX`printf "%05d" $CLONE_NUMBER`
    loginfo "============ Creating clone $CLONE_NAME ============"
    python kvm_sfclone_raw_vm.py --mvip=$SFMVIP --vmhost=$SFVMHOST --vm_name=$SOURCE_VM --clone_name=$CLONE_NAME  || fail "Failed cloning VM"
    VM_COUNT=`python kvm_count_vms.py --vmhost=$SFVMHOST --vm_prefix=$CLONE_PREFIX --bash` || fail "Could not get count of VMs"
done

loginfo "============ Finished deployment ============"
python send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject="Finished `basename $0`"
exit 0
