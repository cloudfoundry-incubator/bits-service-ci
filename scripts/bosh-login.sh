#!/bin/bash -ex

cat vars-store/${HOSTS_ENTRY_FILE} >> /etc/hosts
bosh2 alias-env my-env -e $(cat vars-store/${HOSTS_ENTRY_FILE} | cut -f 2 -d ' ') \
    --ca-cert <(bosh2 int vars-store/${VARS_STORE_FILE} --path /director_ssl/ca)
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int vars-store/${VARS_STORE_FILE} --path /admin_password`
export BOSH_ENVIRONMENT=my-env
