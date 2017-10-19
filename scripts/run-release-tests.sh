#!/bin/bash -ex

cd $(dirname $0)/../../bits-service-system-test-source

export BITS_SERVICE_MANIFEST=./manifest.yml

bosh -u x -p x target $BOSH_TARGET
bosh login $BOSH_USERNAME $BOSH_PASSWORD
bosh download manifest $RELEASE_NAME $BITS_SERVICE_MANIFEST

# bosh2 int ../deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml \
#     --path /default_ca/certificate > /usr/local/share/ca-certificates/bits-service-ca.crt
# update-ca-certificates --verbose
bosh2 int ../deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml --path /bits_service_ssl/ca > /tmp/bits-service-ca.crt
export BITS_SERVICE_CA_CERT=/tmp/bits-service-ca.crt

bundle install
bundle exec rake spec
