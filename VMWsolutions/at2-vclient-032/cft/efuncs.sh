#!/bin/bash

#*****************************************************************************
# efuncs
# Author: Marshall McMullen 5/2011
#*****************************************************************************

#-----------------------------------------------------------------------------
# TRAPS / DIE / STACKTRACE 
#-----------------------------------------------------------------------------

stacktrace() {
    local frame=1

    while caller ${frame}; do
        ((frame++));
    done
}

die() {
    plymouth_pause
    echo ""
    eerror "$@"

    IFS="
"
    local frames=( $(stacktrace) )

    for f in ${frames[@]}; do
        local line=$(echo ${f} | awk '{print $1}')
        local func=$(echo ${f} | awk '{print $2}')
        local file=$(basename $(echo ${f} | awk '{print $3}'))
        
        printf "${RED}   :: %-20s | ${func}${COLOR_OFF}\n" "${file}:${line}" >${EFUNCS_OUTPUT}
    done

    ifs_restore
    trap - EXIT
    kill 0
    exit 1
}

# appends a command to a trap
#
# - 1st arg:  code to add
# - remaining args:  names of traps to modify
#
trap_add() {
    trap_add_cmd=$1; shift || die "${FUNCNAME} usage error"
    for trap_add_name in "$@"; do
        trap -- "$(
            # helper fn to get existing trap command from output
            # of trap -p
            extract_trap_cmd() { printf '%s\n' "$3"; }
            # print the new trap command
            printf '%s\n' "${trap_add_cmd}"
            # print existing trap command with newline
            eval "extract_trap_cmd $(trap -p "${trap_add_name}")"
        )" "${trap_add_name}" \
            || die "unable to add to trap ${trap_add_name}"
    done
}

# set the trace attribute for the above function.  this is
# required to modify DEBUG or RETURN traps because functions don't
# inherit them unless the trace attribute is set
declare -f -t trap_add

# Default trap
trap_add 'die [killed]' HUP INT QUIT BUS PIPE TERM

#-----------------------------------------------------------------------------
# SETUP I/O REDIRECTION
#-----------------------------------------------------------------------------

# Return 0 if using SOL
serial_over_lan() {
    grep -q "console=ttyS" /proc/cmdline
    if [[ $? -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

serial_over_lan && EFUNCS_INPUT="/dev/console " || EFUNCS_INPUT="/dev/stdin"
serial_over_lan && EFUNCS_OUTPUT="/dev/console" || EFUNCS_OUTPUT="/dev/stderr"

redirect=""
[[ ${V} -ne 1 ]] && redirect=" >/dev/null"

#-----------------------------------------------------------------------------
# FUNCTION ARGUMENT HELPERS
#-----------------------------------------------------------------------------

# Check to ensure an argument is non-zero
argcheck() {
    local tag=$1 ; [[ -z "${tag}" ]] && die "Missing argument 'tag'"
    eval "local val=\$${tag}"
    [[ -z "${val}" ]] && die "Missing argument '${tag}'"
}

#-----------------------------------------------------------------------------
# KEYMAPS
#-----------------------------------------------------------------------------

disable_arrowkeys_vtswitch() {
    local new_keymap="/tmp/.disable_arrowkeys_vtswitch.kmap"
    echo "keymaps 0-127"   > ${new_keymap}
    echo "keycode 105 = " >> ${new_keymap}
    echo "keycode 106 = " >> ${new_keymap}
    echo "keycode 103 = " >> ${new_keymap}
    echo "keycode 108 = " >> ${new_keymap}

    loadkeys "${new_keymap}" || die "loadkeys ${new_keymap} failed"
}

#-----------------------------------------------------------------------------
# PLYMOUTH HELPER I/O ROUTINES
#-----------------------------------------------------------------------------

plymouthd_start() {
    plymouthd --mode=boot --attach-to-session || { echo "Failed to start plymouthd"; exit 1; }
}

plymouth_start() {
    serial_over_lan && return

    plymouth_running || plymouthd_start

    ## Prevent arrow keys from switching Virtual Terminals
    disable_arrowkeys_vtswitch
    
    plymouth --show-splash       || { echo "Failed to show splash";     exit 1; }
}

plymouth_stop() {
    serial_over_lan && return

    plymouth --wait quit         || { echo "Failed to quit plythmouh";  exit 1; } 
}

plymouth_restart() {
    serial_over_lan && return
    
    plymouth --wait quit
    plymouth_start
}

plymouth_running() {
    serial_over_lan && return
    
    plymouth --ping
    return $?
}

plymouth_clear() {
    serial_over_lan && return
    
    plymouth --hide-splash
    plymouth --show-splash
}

plymouth_pause() {
    serial_over_lan && return
    
    plymouth_running && plymouth pause-progress
}

plymouth_resume() {
    serial_over_lan && return
    
    plymouth_running && plymouth unpause-progress
}

plymouth_message() {
    serial_over_lan && return
    
    plymouth message --text="$@"
}

plymouth_prompt() {
    serial_over_lan && return
    
    local tmp="/tmp/.plymouth_prompt"
    local result=$(plymouth ask-question --prompt="$@" --command="tee ${tmp}"; rm -f ${tmp})
    echo -en "${result}"
}

plymouth_prompt_timeout() {
    serial_over_lan && return
    
    local timeout=$1 ; shift; [[ -z "${timeout}" ]] && die "Missing timeout value"
    local default=$1 ; shift; [[ -z "${default}" ]] && die "Missing default value"

    local tmp="/tmp/.plymouth_prompt"
    erm ${tmp}
    plymouth ask-question --prompt="$@" --command="tee ${tmp}" &

    local i=0
    while true; do
        if [[ -e ${tmp} ]]; then
            break
        fi

        if [[ ${i} -gt ${timeout} ]]; then
            plymouth_restart
            echo -en "${default}"
            break
        fi

        local left=$((timeout - $i))
        einfo "Will continue in ($left) seconds..."
        sleep 1
        i=$((i+1))
    done

    plymouth_message ""
    erm ${tmp}
}

#-----------------------------------------------------------------------------
# FANCY I/O ROUTINES
#-----------------------------------------------------------------------------
COLOR_ESC="\033["                                                                                                                          
COLOR_OFF="${COLOR_ESC}0m"                                                                                                                 
COLOR_BOLD="${COLOR_ESC}1m"                                                                                                                
COLOR_FAINT="${COLOR_ESC}2m"                                                                                                               
RESET="39;49;00m"                                                                                                                          
BLACK="${COLOR_ESC}30m$COLOR_BOLD"                                                                                                         
RED="${COLOR_ESC}31m$COLOR_BOLD"                                                                                                           
GREEN="${COLOR_ESC}32m$COLOR_BOLD"                                                                                                         
YELLOW="${COLOR_ESC}33m$COLOR_BOLD"                                                                                                        
BLUE="${COLOR_ESC}34m$COLOR_BOLD"                                                                                                          
MAGENTA="${COLOR_ESC}35m$COLOR_BOLD"                                                                                                       
CYAN="${COLOR_ESC}36m$COLOR_BOLD"                                                                                                          
WHITE="${COLOR_ESC}37m$COLOR_BOLD" 

eclear() {
    tput clear >${EFUNCS_OUTPUT}
}

ebanner() {
    echo "" >${EFUNCS_OUTPUT}
    echo -e "${MAGENTA}+----------------------------------------------------------------------------+" >${EFUNCS_OUTPUT}
    echo -e "|" >${EFUNCS_OUTPUT}

    ifs_save
    ifs_nl
    for line in $@; do
        echo -e "| $line" >${EFUNCS_OUTPUT}
    done
    ifs_restore
    
    echo -e "|" >${EFUNCS_OUTPUT}
    echo -e "+----------------------------------------------------------------------------+${COLOR_OFF}" >${EFUNCS_OUTPUT}
}

einfo() {
    local output=$(echo -en "$@" | tr -s "[:space:]" " ")
    echo -e "${GREEN} * $@ ${COLOR_OFF}" >${EFUNCS_OUTPUT}
    plymouth_message "$@"
}

einfon() {
    local output=$(echo -en "$@" | tr -s "[:space:]" " ")
    echo -en "${GREEN} * $@ ${COLOR_OFF}" >${EFUNCS_OUTPUT}
    plymouth_message "$@"
}

einfos() {
    local output=$(echo -en "$@" | tr -s "[:space:]" " ")
    echo -e "${CYAN}   >> $@ ${COLOR_OFF}" >${EFUNCS_OUTPUT}
}

ewarn() {
    local output=$(echo -en "$@" | tr -s "[:space:]" " ")
    echo -e "${YELLOW} * $@ ${COLOR_OFF}" >${EFUNCS_OUTPUT}
    plymouth_running || return

    ## PLYMOUTH ##
    plymouth_message "$@"
    sleep 2
}

eerror() {
    local output=$(echo -en "$@" | tr -s "[:space:]" " ")
    echo -e "${RED}!! $@ !! ${COLOR_OFF}" >${EFUNCS_OUTPUT}
    plymouth_running || return

    ## PLYMOUTH ##
    plymouth_message "$@"
    sleep 5
}

# etable("col1|col2|col3", "r1c1|r1c2|r1c3"...)
etable() {
    columns=$1
    lengths=()
    for line in "$@"; do
        ifs_save; ifs_set "|"; parts=(${line}); ifs_restore
        idx=0
        for p in "${parts[@]}"; do
            mlen=${#p}
            [[ ${mlen} -gt ${lengths[$idx]} ]] && lengths[$idx]=${mlen}
            idx=$((idx+1))
        done
    done

    divider="+"
    ifs_save; ifs_set "|"; parts=(${columns}); ifs_restore
    idx=0
    for p in "${parts[@]}"; do
        len=$((lengths[$idx]+2))
        s=$(printf "%${len}s+")
        divider+=$(echo -n "${s// /-}")
        idx=$((idx+1))
    done

    printf "%s\n" ${divider}

    lnum=0
    for line in "$@"; do
        IFS="|"; parts=(${line}); IFS=" "
        idx=0
        printf "|"
        for p in "${parts[@]}"; do
            pad=$((lengths[$idx]-${#p}+1))
            printf " %s%${pad}s|" "${p}" " "
            idx=$((idx+1))
        done
        printf "\n"
        lnum=$((lnum+1))
        if [[ ${lnum} -eq 1 || ${lnum} -eq $# ]]; then
            printf "%s\n" ${divider}
        else
            printf "%s\n" ${divider//+/|}
        fi
    done
}

eprompt() {
    local output=$(echo -en "$@" | tr -s "[:space:]" " ")
    echo -en "${WHITE} * $@: ${COLOR_OFF}" >${EFUNCS_OUTPUT}
    local result=""

    # If we're using serial over lan do NOT use plymouth
    serial_over_lan && { read result <${EFUNCS_INPUT}; } || result=$(plymouth_prompt "${output}")
    
    echo -en "${result}"
}

eprompt_timeout() {
    local timeout=$1 ; shift; [[ -z "${timeout}" ]] && die "Missing timeout value"
    local default=$1 ; shift; [[ -z "${default}" ]] && die "Missing default value"
    
    local output=$(echo -en "$@" | tr -s "[:space:]" " ")
    echo -en "${WHITE} * $@: ${COLOR_OFF}" >${EFUNCS_OUTPUT}
    local result=""

    # If we're using serial over lan do NOT use plymouth
    serial_over_lan && { read result -t ${timeout} <${EFUNCS_INPUT} || result="${default}"; } || result=$(plymouth_prompt_timeout "${timeout}" "${default}" "$@")
    
    echo -en "${result}"
}

epromptyn() {
    while true; do
        response=$(eprompt "$@ (Y/N)" | tr '[:lower:]' '[:upper:]')
        if [[ ${response} == "Y" || ${response} == "N" ]]; then
            echo -en "${response}"
            return
        fi

        eerror "Invalid response ($response) -- please enter Y or N"
    done
}

epromptyn_timeout() {
    local timeout=$1 ; shift; [[ -z "${timeout}" ]] && die "Missing timeout value"
    local default=$1 ; shift; [[ -z "${default}" ]] && die "Missing default value"

    while true; do
        local response=$(eprompt_timeout "${timeout}" "${default}" "$@ (Y/N)" | tr '[:lower:]' '[:upper:]')
        if [[ ${response} == "Y" || ${response} == "N" ]]; then
            echo -en "${response}"
            return
        fi

        eerror "Invalid response ($response) -- please enter Y or N"
    done
}

trim() {
    echo "$1" | sed 's|^[ \t]\+||'
}

strip() {
    echo ${1//[[:space:]]}
}

eend() {
    local rc=${1:-0} #sets rc to first arg if present otherwise defaults to 0

    if [[ "${rc}" == "0" ]]; then
        echo -e "${BLUE}[${GREEN} ok ${BLUE}]${COLOR_OFF}" >${EFUNCS_OUTPUT}
    else
        echo -e "${BLUE}[${RED} !! ${BLUE}]${COLOR_OFF}" >${EFUNCS_OUTPUT}
    fi
}

ekill() {
    kill ${1} >/dev/null 2>&1 || die "Failed to kill ${1}"
}

__EPROGRESS_PID=-1

do_eprogress() {
    while true; do 
        echo -n "."
        sleep 1
    done
}

eprogress() {
    einfon $@

    # This complex redirection allows us to suppress bash stderr when we later kill eprogress
    # but still get the output from do_eprogress
    do_eprogress 2>/dev/null &
    __EPROGRESS_PID=$!    
}

eprogress_kill() {
    local rc="${1}"; [[ -z "${rc}" ]] && rc="0"
    ekill ${__EPROGRESS_PID}
    eend ${rc}
}

#-----------------------------------------------------------------------------
# MISC PARSING FUNCTIONS
#-----------------------------------------------------------------------------
parse_tag_value_internal() {
    local input=$1
    local array=()
    tag=$(echo ${input} | cut -d= -f1)
    val=$(echo ${input} | cut -d= -f2 | tr -d '\"')

    array=( ${tag} ${val} )
    rtr=(${array[@]})
    
    parts=(${rtr[@]})
    echo -n "${parts[1]}"
}

parse_tag_value() {
    local path=$1
    local tag=$2
    local prefix=$3
    local output=$(cat ${path} | grep "^${tag}=")
    
    if [[ "${output}" != "" ]]; then
        echo -n "${prefix}$(parse_tag_value_internal ${output})"
    fi
}

ifs_save() {
    export IFS_SAVE=${IFS}
}

ifs_restore() {
    export IFS=${IFS_SAVE}
}

ifs_nl() {
    export IFS="
"
}

ifs_space() {
    export IFS=" "
}

ifs_set() {
    export IFS="${1}"
}

config_set_value() {
    local tag=$1 ; argcheck 'tag'; shift
	eval "local val=$(trim \${$tag})" || die
    for cfg in $@; do
        sed -i "s|\${$tag}|${val}|g" "${cfg}" || die "Failed to update ${tag} in ${cfg}"
    done
}

# Check no unexpanded variables in given config file or else die
config_check() {
	local cfg=$1 ; argcheck 'cfg'; shift
	grep "\${" "${cfg}" -qs && die "Failed to replace all variables in ${cfg}"
}

valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        ifs_save; ifs_set '.'; ip=($ip); ifs_restore
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

getipaddress()
{
	local iface=$1; argcheck 'iface'; 
	local ip=$(strip $(/sbin/ifconfig ${iface} | grep -o 'inet addr:\S*' | cut -d: -f2))
	echo -n "${ip}"
}

getnetmask()
{	local iface=$1; argcheck 'iface'; 
	local netmask=$(strip $(/sbin/ifconfig ${iface} | grep -o 'Mask:\S*' | cut -d: -f2))
	echo -n "${netmask}"
}

getbroadcast()
{
	local iface=$1; argcheck 'iface'; 
	local bcast=$(strip $(/sbin/ifconfig ${iface} | grep -o 'Bcast::\S*' | cut -d: -f2))
	echo -n "${bcast}"
}

# Gets the default gateway that is currently in use
getgateway()
{
	local gw=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
	echo -n "${gw}"
}

#-----------------------------------------------------------------------------
# MISC FS HELPERS
#-----------------------------------------------------------------------------
epushd() {
    pushd $1 >/dev/null || die "pushd $1 failed"
}
epopd() {
    popd $1 >/dev/null    || die "popd failed"
}

emkdir() {
    [[ -d "${1}" ]] || mkdir -p ${1} || die "emkdir '${1}' failed"
}

ecp() {
    eval "cp -arL ${1} ${2}" || die "ecp '${1}' => '${2}' failed"
}

ecp_try() {
    eval "cp -arL ${1} ${2}" || ewarn "ecp '${1}' => '${2}' failed"
}

erm() {
    eval "rm -rf $@" || die "rm -rf $@ failed"
}

erm_try() {
    eval "rm -rf $@" || ewarn "rm -rf $@ failed"
}

ermdir() {
    eval "rmdir $@" || die "rmdir $@ failed"
}

emv() {
    mv "${1}" "${2}" || die "emv '${1}' => '${2}' failed"
}

ersync() {
    local flags="-azl"
    [[ ${V} -eq 1 ]] && flags+="vh"
    eval "rsync ${flags} ${1} ${2}" || die "rsync ${1} => ${2} failed"
}

erename() {
    local src=$1
    local dst=$2

    emkdir $dst
    ersync "${src}/" "${dst}/"
    erm ${src}
}

# Unmount (if mounted) and remove directory (if it exists) then create it anew
efreshdir() {
    local mnt=${1}

    unmount_recursive ${mnt}
    erm ${mnt}
    emkdir ${mnt}
}

# Renames the given file to *.bak if it doesn't already exist
ebackup() {
    local src=$1

    [[ -e "${src}" && ! -e "${src}.bak" ]] && emv "${src}" "${src}.bak"
}

erestore() {
    local src=$1
    
    [[ -e "${src}.bak" ]] && emv "${src}.bak" "${src}"
}

etar() {
    eval "tar $@ --checkpoint=1000 --checkpoint-action=dot" || die "tar $@ failed"
}

#-----------------------------------------------------------------------------                                    
# MOUNT / UMOUNT UTILS
#-----------------------------------------------------------------------------                                    
# Conditionally unmount if something is mounted
unmount() {
    local dev=${1}

    if [[ $(cat /proc/mounts | grep --color=never "${dev}" | awk '{print $2}' ) ]]; then
        umount -l ${dev}
    fi

    if [[ $(cat /proc/mounts | grep --color=never "${dev}" | awk '{print $2}' ) ]]; then
        die "${dev} still mounted!"
    fi
}

unmount_recursive() {
    ifs_save
    ifs_nl

    local mnt=${1} 
    local mounts="$(cat /proc/mounts | grep --color=never "${mnt}" | awk '{print $2}' | sort -r)"
    for m in ${mounts}; do
        unmount ${m}
    done

    ifs_restore
}

#-----------------------------------------------------------------------------
# MISC HELPERS
#-----------------------------------------------------------------------------
ecmd() {
    local cmd="$@"
    eval "${cmd}" || die "Failed to execute [$cmd]"
}

ecmd_try() {
    local cmd="$@"
    eval "${cmd}" || ewarn "Failed to execute [$cmd]"
}

etouch() {
    ecmd "touch $@"
}

numcores() {
    echo $(cat /proc/cpuinfo | grep "processor" | wc -l)
}

einstall() {
    SUDOCMD=""
    [[ $EUID != 0 ]] && SUDOCMD="sudo"
    if [[ -e "/etc/lsb-release" ]]; then
        $SUDOCMD apt-get install -qq $@ >/dev/null || die "Failed to install $@"
    else
        die "Unsupported OS -- please install $@"
    fi
}

efetch() {
    local dest=~/Downloads
    [[ ! -e ${dest} ]] && dest=/tmp
    dest+="/$(basename ${1})"

    einfos "Fetching [${1}] to [${dest}]"
    [[ -f ${dest} ]] && timecond="--time-cond ${dest}"
    ecmd curl "${1}" ${timecond} --output "${dest}" --location --fail --silent
    echo -n ${dest}
}


enslookup() {
    if [[ $(nslookup -fail $1 | grep SERVFAIL | wc -l) -eq 0 ]]; then
        echo -en 'jenkins'
    else
        echo -en ${2}
    fi
}
