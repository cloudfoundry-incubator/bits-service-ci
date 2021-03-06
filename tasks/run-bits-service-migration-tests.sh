#!/bin/bash -e

if [ -n "$DEBUG" ]; then
  set -x
  export
  go version
fi

cf_admin_password=$( \
  bosh2 int deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}-bosh-lite/cf-deployment/vars.yml \
  --path /cf_admin_password
)
CF_DOMAIN=$(cat deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}-bosh-lite/hosts | cut -d ' ' -f1 ).nip.io

export GOPATH=$(mktemp -d)
export PATH=$GOPATH/bin:$PATH

mkdir -p $GOPATH/src/github.com/cloudfoundry-incubator $GOPATH/bin $GOPATH/pkg
cp -a bits-service-migration-tests $GOPATH/src/github.com/cloudfoundry-incubator
cd $GOPATH/src/github.com/cloudfoundry-incubator/bits-service-migration-tests

glide install
pushd vendor/github.com/onsi/ginkgo/ginkgo
    go install
popd

cat >config.json <<EOF
{
  "api": "api.${CF_DOMAIN}",
  "apps_domain": "${CF_DOMAIN}",
  "admin_user": "admin",
  "admin_password": "${cf_admin_password}",
  "skip_ssl_validation": true,
  "use_http": true,
  "backend": "diego",
  "default_timeout": 75,
  "cf_push_timeout": 240,
  "persistent_app_org": "${BSMT_PERSISTENT_ORG}",
  "persistent_app_space": "${BSMT_PERSISTENT_SPACE}"
}
EOF
export CONFIG="$(readlink -nf config.json)"

ginkgo -r $noColorFlag -slowSpecThreshold=120 -randomizeAllSpecs $verbose -keepGoing $test_suite
