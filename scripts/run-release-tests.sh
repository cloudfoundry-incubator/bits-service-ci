#!/bin/bash -e

cd $(dirname $0)/../../bits-service-system-test-source

export BITS_SERVICE_MANIFEST=./manifest.yml

bosh -u x -p x target $BOSH_TARGET Lite
bosh login $BOSH_USERNAME $BOSH_PASSWORD
bosh download manifest $RELEASE_NAME $BITS_SERVICE_MANIFEST

bundle install
bundle exec rake spec
