# Create clones on multiple volumes in parallel`

MVIP=192.168.154.1
VOLUME_PREFIX=vol
CLONE_COUNT=1



INDEX=1
while [ "$INDEX" -lt 20 ]; do
    VOLUME_NAME=`printf "${VOLUME_PREFIX}%05d" $INDEX`
    clone_volume.py --mvip=$MVIP --volume_name=$VOLUME_NAME --clone_count=$CLONE_COUNT &
    INDEX=$[INDEX + 1]
done

joblist=( $(jobs -p) )
num=1
njobs=${#joblist[*]}
for job in ${joblist[*]}; do
    wait $job
    num=$((num+1))
done
