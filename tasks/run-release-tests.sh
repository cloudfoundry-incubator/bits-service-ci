#!/bin/bash -ex

cd $(dirname $0)/../../bits-service-system-test-source

echo "${DIRECTOR_IP} ${DIRECTOR_NAME}" >> /etc/hosts

export BOSH_CLIENT=$BOSH_USERNAME
export BOSH_CLIENT_SECRET=$BOSH_PASSWORD
export BOSH_DEPLOYMENT=$DEPLOYMENT_NAME
export BOSH_ENVIRONMENT=my-env

bosh2 alias-env my-env -e $DIRECTOR_NAME --ca-cert <(bosh2 int ../deployment-vars/environments/${ENVIRONMENT_NAME}/director/vars.yml --path /director_ssl/ca)
bosh2 login

bosh2 manifest > manifest.yml
export BITS_SERVICE_MANIFEST=manifest.yml
bosh2 int ../deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml --path /bits_service_ssl/ca > /tmp/bits-service-ca.crt
export BITS_SERVICE_CA_CERT=/tmp/bits-service-ca.crt

bundle install
bundle exec rake spec
