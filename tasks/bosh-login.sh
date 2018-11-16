#!/bin/bash -ex

cat vars-store/${HOSTS_ENTRY_FILE} >> /etc/hosts
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int vars-store/${VARS_STORE_FILE} --path /admin_password`
export BOSH_ENVIRONMENT=$(cat vars-store/${HOSTS_ENTRY_FILE} | cut -f 2 -d ' ')
export BOSH_CA_CERT=$(bosh2 int vars-store/${VARS_STORE_FILE} --path /director_ssl/ca)
export BOSH_NON_INTERACTIVE=true

if [ "$USE_BOSH_ALL_PROXY" == 'true' ]; then
    JUMPBOX_KEY=$(mktemp)
    bosh2 interpolate vars-store/${JUMPBOX_VARS_STORE_FILE} --path /jumpbox_ssh/private_key > ${JUMPBOX_KEY}
    chmod 600 ${JUMPBOX_KEY}
    export BOSH_ALL_PROXY=ssh+socks5://jumpbox@$(bosh2 interpolate vars-store/${JUMPBOX_VARS_FILE} --path /jumpbox_url)?private-key=${JUMPBOX_KEY}
fi
