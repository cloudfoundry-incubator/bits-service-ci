#!/bin/bash -ex

router_ip=$(cat deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}/hosts | cut -d ' ' -f1)

TOKEN=$(curl https://api.dynu.com/v1/oauth2/token \
        -H "Accept: application/json" \
        -H "Accept-Language: en_US" \
        -u "$DYNU_CLIENT_ID:$DYNU_SECRET" \
        -d "grant_type=client_credentials" \
        | jq -r .accessToken)

curl https://api.dynu.com/v1/dns/delete/$SYSTEM_DOMAIN \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN"

OUTPUT=$(curl -X POST https://api.dynu.com/v1/dns/add \
        -d "{\"name\": \"$SYSTEM_DOMAIN\", \"ipv4_address\":\"$router_ip\"}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN")

STATE=$(echo $OUTPUT | jq -r .state)

if [[ "$STATE" != 'Complete' ]]; then
    echo "Could not create DNS entry. Error message from dynu:"
    echo $OUTPUT
    exit 1
fi
