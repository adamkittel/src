NODE_IP=$1
METHOD=$2
PARAMS=$3
USER=$4
PASSWORD=$5
VERSION=$6

if [[ -z "$USER" ]]; then
    USER=admin
fi
if [[ -z "$PASSWORD" ]]; then
    PASSWORD=admin
fi

if [[ -z "$VERSION" ]]; then
    VERSION=6.0
fi
RESULT=$(curl --connect-timeout 10 --max-time 180 -sS --insecure --user $USER:$PASSWORD "https://$NODE_IP:442/json-rpc/$VERSION" --data '{"method":"'"$METHOD"'", "params":{'"$PARAMS"'}}')
echo $RESULT | grep -q "found on this server"
if [[ "$?" = "0" ]]; then
    echo $RESULT
    exit 1
else
    echo $RESULT | jq -C .result
fi

