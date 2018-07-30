#!/bin/bash -ex

cat vars-store/${HOSTS_ENTRY_FILE} >> /etc/hosts
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int vars-store/${VARS_STORE_FILE} --path /admin_password`
export BOSH_ENVIRONMENT=$(cat vars-store/${HOSTS_ENTRY_FILE} | cut -f 2 -d ' ')
export BOSH_CA_CERT=$(bosh2 int vars-store/${VARS_STORE_FILE} --path /director_ssl/ca)
export BOSH_NON_INTERACTIVE=true

if [ $BOSH_ALL_PROXY_FILE ]; then
    export BOSH_ALL_PROXY=$(cat ${BOSH_ALL_PROXY_FILE})
fi
