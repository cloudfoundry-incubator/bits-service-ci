#!/bin/bash -ex

. ci-tasks/scripts/start-collectd.sh
start_collectd

# .count is needed because Bluemix Logmet/Grafana does not roll up sparse
# metrics correctly, when the range is >24h.
echo "performance-test-run.count:1|c" | nc -u -w1 127.0.0.1 8125

cat <<EOT > $PWD/bits-service-release/src/github.com/cloudfoundry-incubator/bits-service-performance-tests/integration_aws_config.json
{
  "api": "api.${CF_DOMAIN}",
  "apps_domain": "${CF_DOMAIN}",
  "admin_user": "${CF_ADMIN_USER}",
  "admin_password": "${CF_ADMIN_PASSWORD}",
  "skip_ssl_validation": true,
  "use_http": true
}
EOT

export CONFIG=$PWD/bits-service-release/src/github.com/cloudfoundry-incubator/bits-service-performance-tests/integration_aws_config.json
export GOPATH=$PWD/bits-service-release
export PATH=$GOPATH/bin:$PATH
pushd bits-service-release/src/github.com/onsi/ginkgo/ginkgo
  go install
popd

pushd bits-service-release/src/github.com/cloudfoundry-incubator/bits-service-performance-tests
  glide install
  ginkgo -v --progress
popd
