#!/bin/bash -ex

export BITS_SERVICE_MANIFEST=$PWD/manifest.yml

bosh -u x -p x target $BOSH_TARGET
bosh login $BOSH_USERNAME $BOSH_PASSWORD
bosh download manifest $DEPLOYMENT_NAME $BITS_SERVICE_MANIFEST

  # TODO: `grep bits-service` again, once bits-service is not co-located on api anymore
export BITS_SERVICE_PRIVATE_ENDPOINT_IP=$(
  bosh vms ${DEPLOYMENT_NAME} \
  | grep ' api' \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
)

bosh2 int deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml \
    --path /default_ca/certificate > /tmp/ca-cert
export BITS_SERVICE_CA_CERT=/tmp/ca-cert

export CC_API="api.${CF_DOMAIN}"
export CC_PASSWORD=$(
  bosh2 int deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml \
    --path /cf_admin_password
)
export CC_USER=admin

echo "${BITS_SERVICE_PRIVATE_ENDPOINT_IP} bits-service.service.cf.internal" >> /etc/hosts

cd $(dirname $0)/../../bits-service-system-test-source

bundle install
bundle exec rspec --tag ~type:limits
