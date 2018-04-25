#!/bin/bash -ex

echo "${DIRECTOR_IP} ${DIRECTOR_NAME}" >> /etc/hosts

export BOSH_CLIENT=$BOSH_USERNAME
export BOSH_CLIENT_SECRET=$BOSH_PASSWORD
export BOSH_ENVIRONMENT=my-env

bosh2 alias-env my-env -e $DIRECTOR_NAME --ca-cert <(bosh2 int deployment-vars/environments/${ENVIRONMENT_NAME}/director/vars.yml --path /director_ssl/ca)
bosh2 login

bosh2 -d cf instances > instances

router_ip=$(grep -E '^router' instances | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
bits_service_ip=$(grep -E '^api' instances | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

curl -vvv -u $CHANGE_IP_USER:$CHANGE_IP_PASSWORD \
    "https://nic.ChangeIP.com/nic/update?hostname=*.cf-deployment.dynamic-dns.net&ip=$router_ip" | \
    grep '200 Successful Update'

curl -vvv -u $CHANGE_IP_USER:$CHANGE_IP_PASSWORD \
    "https://nic.ChangeIP.com/nic/update?hostname=bits.cf-deployment.dynamic-dns.net&ip=$bits_service_ip" | \
    grep '200 Successful Update'
