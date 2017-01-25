MVIP=$1
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
RESULT=$(curl --connect-timeout 10 --max-time 180 -sS --insecure --user $USER:$PASSWORD "https://$MVIP/json-rpc/$VERSION" --data '{"method":"'"$METHOD"'", "params":{'"$PARAMS"'}}')
echo $RESULT | grep -q "found on this server"
if echo $RESULT | grep -q "found on this server"; then
    echo $RESULT
    exit 1
elif echo $RESULT | grep -q "Unauthorized"; then
    echo "Invalid Username/password"
    exit 1
elif echo $RESULT | grep -q '{"error":'; then
    echo $RESULT | jq -C .error
else
    echo $RESULT | jq -C .result
fi
