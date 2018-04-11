#!/bin/bash -ex

export BITS_SERVICE_MANIFEST=$(readlink -f vars-store/environments/softlayer/director/${ENVIRONMENT_NAME}/cf-deployment/manifest.yml)

export BITS_SERVICE_PRIVATE_ENDPOINT_IP=1.2.3.4 # not-used-for-these-tests

bosh2 int vars-store/environments/softlayer/director/${ENVIRONMENT_NAME}/cf-deployment/vars.yml --path /router_ssl/ca > /tmp/router-ca.crt
export BITS_SERVICE_CA_CERT=/tmp/router-ca.crt

export CC_API="api.$(cat vars-store/environments/softlayer/director/${ENVIRONMENT_NAME}/cf-deployment/system_domain)"
export CC_PASSWORD=$(bosh2 int vars-store/environments/softlayer/director/${ENVIRONMENT_NAME}/cf-deployment/vars.yml --path /cf_admin_password)
export CC_USER=admin

echo "$(cat vars-store/environments/softlayer/director/${ENVIRONMENT_NAME}/ip) bits-service.service.cf.internal" >> /etc/hosts

cd bits-service-release

bundle install
bundle exec rspec spec/cf_spec.rb
bundle exec rspec spec/packages_spec.rb --example "with CC updates enabled"
