#!/bin/bash -ex


echo "${DIRECTOR_IP} ${DIRECTOR_NAME}" >> /etc/hosts

export BOSH_CLIENT=$BOSH_USERNAME
export BOSH_CLIENT_SECRET=$BOSH_PASSWORD
export BOSH_DEPLOYMENT=$DEPLOYMENT_NAME
export BOSH_ENVIRONMENT=$DIRECTOR_NAME
if [ "$VARS_YAML" != "" ]; then
    export BOSH_CA_CERT=$(bosh2 int ${VARS_YAML} --path /director_ssl/ca)
    bosh2 int ${VARS_YAML} --path /sl_sshkey/private_key > /tmp/private.key
    export BOSH_ALL_PROXY=ssh+socks5://root@${DIRECTOR_NAME}:22?private-key=/tmp/private.key
    chmod 600 /tmp/private.key
else
    export BOSH_CA_CERT=$(bosh2 int deployment-vars/environments/${ENVIRONMENT_NAME}/director/vars.yml --path /director_ssl/ca)
fi

cd $(dirname $0)/../../bits-service-system-test-source

bosh2 manifest > manifest.yml
export BITS_SERVICE_MANIFEST=manifest.yml
bosh2 int ../deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml --path /bits_service_ssl/ca > /tmp/bits-service-ca.crt
export BITS_SERVICE_CA_CERT=/tmp/bits-service-ca.crt

bundle install
bundle exec rake spec
