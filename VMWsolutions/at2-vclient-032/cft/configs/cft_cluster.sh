export SFEMAIL_NOTIFY=carl.seelye@solidfire.com
export SFMVIP=172.25.104.200
export SFSVIP=10.5.5.200
export SFUSERNAME=script_user
export SFPASSWORD=solidfire
export SFIPMI_USER=root
export SFIPMI_PASS=ironclads

source ../libsf.sh
logdebug "Starting"
fail()
{
    loginfo $1
    exit 1
}
export SFNODE_IPS=`python ../get_active_nodes.py --mvip=$SFMVIP --csv` || fail "Could not get list of nodes from cluster"
IFS="," read -a SFNODE_LIST <<< "$SFNODE_IPS"

echo
echo
loginfo "The following variables are now available:"
for v in `compgen -v | grep "^SF"`; do
    if declare -p $v | grep -q -- -a; then
        loggreen "`declare -p $v | cut -d' ' -f3-`"
    else
        loggreen "$v=${!v}"
    fi
done
echo
echo
