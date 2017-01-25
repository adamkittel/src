#!/usr/bin/env bash
set -eu
set -o pipefail

# Set defaults unless they have already been set in the environment
: ${SF_VERSION:=}
: ${RELEASE:=oxygen}
: ${CREATE_OVA:=0}
: ${INSTALL_VCP:=0}
: ${VM_NAME:=}
: ${VM_HOST:=}
: ${VM_NETWORK:=}
: ${VM_DATASTORE:=}
: ${MGMT_SERVER:=192.168.100.10}
: ${MGMT_USERNAME:=administrator}
: ${MGMT_PASSWORD:=solidfire}
: ${TIMEOUT:=600}
: ${MEM_SIZE:=1}
: ${CPU_COUNT:=1}
: ${DISK_SIZE:=100}
: ${JENKINS_IP:=192.168.137.1}
: ${VM_USER:=sfadmin}
: ${VM_PASS:=LoxBoils9019K}
: ${VMHOST_USER:=root}
: ${VMHOST_PASS:=solidfire}
: ${VCP_VERSION=2.1}
: ${VCP_VERSION_LONG=${VCP_VERSION}.2.5}

usage()
{
    echo "$0 usage"
    echo "  --vm-name, -n       the name of the VM to image"
    echo "  --version, -v       the version to image (ex. 8.0.0.1200)"
    echo "  --release, -r       the release branch to use (ex. oxygen, "
    echo "                      oxygen-oxygen-carl-cases)"
    echo "                      [${RELEASE}]"
    echo "  --ova,              export an OVA after imaging the node"
    echo "  --vcp               install the VCP in the node"
    echo "  --vm-host, -t       the name of the VM host server to use (if "
    echo "                      creating a VM)"    
    echo "  --vm-network, -e    the name of the VM network to use (if "
    echo "                      creating a VM)"
    echo "  --vm-datastore, -d  the name of the datastore to use (if "
    echo "                      creating a VM), or if not specified a "
    echo "                      datastore will be auto selected"
    echo "  --mgmt-server, -s   the IP address of the vSphere vCenter "
    echo "                      management server"
    echo "                      [${MGMT_SERVER}]"
    echo "  --mgmt-user, -m     the username for vSphere"
    echo "                      [${MGMT_USERNAME}]"
    echo "  --mgmt-pass, -a     the password for vSphere"
    echo "                      [${MGMT_PASSWORD}]"
    echo
    echo "If vm-name is specified and the VM exists, the VM with that "
    echo "name is used. If vm-name is specified and it does not exist, "
    echo "a VM with that name is created.  If vm-name is not specified, "
    echo "a random name is generated and a VM is created."
    echo "If vm-datastore is specified, the VM will be created in that "
    echo "datastore.  If it is not specified, the datastore with the most "
    echo "free space will be used"
}

log()
{
   local message="$@"
   if [[ -n ${message} ]]; then
       logger -i -t sftest "${message}"
       printf ">>> ${message}\n"
       return 0
   fi
   
   while read message; do
       logger -i -t sftest "${message}"
       printf ">>> ${message}\n"
   done
}

# Command line options
SHORT_OPTIONS="v:      r:               n:       t:       e:          d:            s:         m:         a:"
LONG_OPTIONS="version: release: ova vcp vm-name: vm-host: vm-network: vm-datastore: mgmt-server: mgmt-user: mgmt-pass:"

SHORT_OPTIONS=$(echo "${SHORT_OPTIONS}" | tr -s '[:space:]' ',')
LONG_OPTIONS=$(echo "${LONG_OPTIONS}" | tr -s '[:space:]' ',')
OPTVAL=$(getopt --alternative --options -h,${SHORT_OPTIONS} --long help,${LONG_OPTIONS} -n '$0' -- "$@")
eval set -- "${OPTVAL}"
while true; do
    case "$1" in
        -h|--help)          usage               ; exit 0    ;;
        -v|--version)       SF_VERSION=$2       ; shift 2   ;;
        -r|--release)       RELEASE=$2          ; shift 2   ;;
        --ova)              CREATE_OVA=1        ; shift 2   ;;
        --vcp)              INSTALL_VCP=1       ; shift 2   ;;
        -t|--vm-host)       VM_HOST=$2          ; shift 2   ;;
        -n|--vm-name)       VM_NAME=$2          ; shift 2   ;;
        -e|--vm-network)    VM_NETWORK=$2       ; shift 2   ;;
        -d|--vm-datastore)  VM_DATASTORE=$2     ; shift 2   ;;
        -s|--mgmt-server)     MGMT_SERVER=$2      ; shift 2   ;;
        -m|--mgmt-user)     MGMT_USERNAME=$2    ; shift 2   ;;
        -a|--mgmt-pass)     MGMT_PASSWORD=$2    ; shift 2   ;;
        --) shift ; break ;;
        *) echo "Internal error: $1"; exit 1    ;;
    esac
done
EXTRA_ARGS="$@"

[[ -z ${SF_VERSION} ]] && { log "Missing version"; exit 1; }

# Generate a random VM if one is not specified
if [[ -z ${VM_NAME} ]]; then

    [[ -z ${VM_HOST} ]] && { log "Missing vm-host"; exit 1; }
    [[ -z ${VM_NETWORK} ]] && { log "Missing vm-network"; exit 1; }

    log "Generate a random VM name and make sure it is not in use"
    which openssl >/dev/null || { log "openssl not installed"; exit 1; }
    while true; do
        set +e
        VM_NAME="sfmnode-$(openssl rand -base64 16 | grep -o '[[:alnum:]]' | head -n 8 | tr -d '\n')"
        set -e
        python vmware_vm_exists.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" || { VM_EXISTS=0; break; }
    done
fi

log "Check if ${VM_NAME} exists"
if ! python vmware_vm_exists.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}"; then
    log "Create the VM ${VM_NAME}"
    if [[ -z ${VM_DATASTORE} ]]; then
        python vmware_create_vm.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vmhost=${VM_HOST} --vm_name="${VM_NAME}" --mem_size=${MEM_SIZE} --cpu_count=${CPU_COUNT} --disk_size=${DISK_SIZE} --network="${VM_NETWORK}"
    else
        python vmware_create_vm.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vmhost=${VM_HOST} --vm_name="${VM_NAME}" --mem_size=${MEM_SIZE} --cpu_count=${CPU_COUNT} --disk_size=${DISK_SIZE} --network="${VM_NETWORK}" --datastore="${VM_DATASTORE}"
    fi
fi

log "Get the MAC address of ${VM_NAME}"
VM_MAC=$(python vmware_get_vm_mac_address.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --bash ${EXTRA_ARGS})

log "Create the PXE boot file"
python create_pxe_file.py --mac_address=${VM_MAC} --release=${RELEASE} --version=${SF_VERSION} ${EXTRA_ARGS}

log "Set the VM to PXE boot"
python vmware_set_vm_boot_order.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --boot_order='net' ${EXTRA_ARGS}

log "Power off the VM"
python vmware_poweroff_vm.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" ${EXTRA_ARGS}

log "Set the VM RAM to 8GB so that it can PXE boot and load our large image"
ORIGINAL_MEM=$(python vmware_get_vm_memory.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --bash ${EXTRA_ARGS})
python vmware_set_vm_memory.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --mem=8 ${EXTRA_ARGS}

log "Power on the VM so that it will PXE boot, then wait for it to shut down at the end of RTFI"
python vmware_poweron_vm.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" ${EXTRA_ARGS}
python vmware_wait_for_vm_poweroff.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --timeout=${TIMEOUT} ${EXTRA_ARGS}

log "Remove the PXE config file"
python delete_pxe_file.py --mac_address=${VM_MAC}

log "Restore the VM memory back to its previous value"
python vmware_set_vm_memory.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --mem=${ORIGINAL_MEM} ${EXTRA_ARGS}

log "Set the VM to boot from local disk and power it up"
python vmware_set_vm_boot_order.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --boot_order='cd,hd,net' ${EXTRA_ARGS}
python vmware_poweron_vm.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" ${EXTRA_ARGS}

log "Wait until the VM is up and VMware tools are running"
python vmware_wait_for_vm_booted.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" ${EXTRA_ARGS}

# Install VCP
if [[ ${INSTALL_VCP} -eq 1 ]]; then

    log "Get the IP address of ${VM_NAME}"
    VM_IP=$(python vmware_get_vm_ip_address.py --mgmt_server=${MGMT_SERVER} --mgmt_user="${MGMT_USERNAME}" --mgmt_pass="${MGMT_PASSWORD}" --vm_name="${VM_NAME}" --bash ${EXTRA_ARGS})

    log "Add ubuntu sources.list to ${VM_NAME}"
    echo > ubuntu.list <<EOF
deb http://us.archive.ubuntu.com/ubuntu/ precise main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu precise-security main restricted universe multiverse
EOF
    sshpass -p "${VM_PASS}" scp ubuntu.list ${VM_USER}@${VM_IP}: 2>&1 | log
    sshpass -p "${VM_PASS}" ssh ${VM_USER}@${VM_IP} "echo \"${VM_PASS}\" | sudo -S mv ubuntu.list /etc/apt/sources.list.d/" 2>&1 | log
    rm -f ubuntu.list

    log "Install VCP in ${VM_NAME}"
    sshpass -p "${VM_PASS}" ssh ${VM_USER}@${VM_IP} "curl http://${JENKINS_IP}/calsoft/vcp${VCP_VERSION_LONG}/install_vcp.sh -O" 2>&1 | log
    sshpass -p "${VM_PASS}" ssh ${VM_USER}@${VM_IP} "echo \"${VM_PASS}\" | sudo -S bash install_vcp.sh" 2>&1 | log
fi

# Create OVA
if [[ ${CREATE_OVA} -eq 1 ]]; then
    log "Zero out the free space in ${VM_NAME}"
    sshpass -p "${VM_PASS}" ssh ${VM_USER}@${VM_IP} "dd if=/dev/zero of=zero bs=5120M; rm zero" 2>&1 | log

    log "Shutdown ${VM_NAME}"
    sshpass -p "${VM_PASS}" ssh ${VM_USER}@${VM_IP} "shutdown now -h" 2>&1 | log

    log "Finding ${VM_NAME} vmdk file on ${VM_HOST}"
    VMDK_PATH=$(sshpass -p "${VMHOST_PASS}" ${VMHOST_USER}@${VMHOST} "find /vmfs/volumes -name \"${VM_NAME}.vmdk\" | head -1")
    [[ -z ${VMDK_PATH} ]] && { log "Could not find ${VM_NAME} vmdk path"; exit 1; }

    log "Hole punching ${VMDK_PATH} on ${VM_HOST}"
    sshpass -p "${VMHOST_PASS}" ${VMHOST_USER}@${VMHOST} "vmkfstools --punchzero \"${VMDK_PATH}\"" | log

    log "Exporting ${VM_NAME} to OVF"
    OVA_BASENAME=solidfire-fdva-${SF_ELEMENT}-${SF_VERSION}-vcp-${VCP_VERSION_LONG}
    ovftool --annotation="SolidFire Management Node ${VERSION} + VCP ${VCP_VERSION}" --powerOffSource vi://${VMHOST_USER}:${VMHOST_PASS}@${VM_HOST}/${VM_NAME} ${OVA_BASENAME}.ovf | log
fi

