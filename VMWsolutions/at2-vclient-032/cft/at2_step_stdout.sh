STEP_ID=$1
curl -sS --insecure --user automation:solidfire 'https://autotest2.solidfire.net/json-rpc/1.0' --data '{"method":"GetTaskInstanceStepStdout", "params":{"taskInstanceStepID":'"$STEP_ID"'}}' | jq .result.stdout | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'

