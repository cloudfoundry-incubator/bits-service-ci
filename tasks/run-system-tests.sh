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

export ROUTER_IP=$(
  bosh vms ${DEPLOYMENT_NAME} \
  | grep ' router' \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
)

echo "$ROUTER_IP  api.cf-deployment.dynamic-dns.net" >> /etc/hosts
echo "$ROUTER_IP  uaa.cf-deployment.dynamic-dns.net" >> /etc/hosts
echo "$BITS_SERVICE_PRIVATE_ENDPOINT_IP  bits.cf-deployment.dynamic-dns.net" >> /etc/hosts

bosh2 int deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml --path /bits_service_ssl/ca > /tmp/bits-service-ca.crt
export BITS_SERVICE_CA_CERT=/tmp/bits-service-ca.crt

export CC_API="api.${CF_DOMAIN}"
export CC_PASSWORD=$(
  bosh2 int deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml \
    --path /cf_admin_password
)
export CC_USER=admin

echo "${BITS_SERVICE_PRIVATE_ENDPOINT_IP} bits.service.cf.internal" >> /etc/hosts

cd $(dirname $0)/../../bits-service-system-test-source

bundle install
bundle exec rspec --tag ~type:limits

echo "IMPORTANT: When this test fails with 'No route to host', make sure our dyndns entries on changeip.com point to the correct IPs within the CF deployment."
echo "Access to changeip.com is in LastPass."
