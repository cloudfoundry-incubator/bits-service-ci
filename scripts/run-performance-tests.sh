#!/bin/bash -ex


function start_collectd {
  cat <<EOT > /etc/collectd/collectd.conf.d/mt-metrics-writer.conf.sample
  LoadPlugin write_metric_mtlumberjack
  <Plugin write_metric_mtlumberjack>
     <Logstash>
         Host "metrics.opvis.bluemix.net"
         Port "9095"
         GraphitePrefix "SPACE_ID.GROUP_NAME."
         SpaceId "SPACE_ID"
         LoggingToken "LOGGING_TOKEN"
     </Logstash>
  </Plugin>
  LoadPlugin statsd
  <Plugin statsd>
    Host "127.0.0.1"
    DeleteCounters true
    DeleteTimers true
    DeleteGauges true
    DeleteSets true
    TimerPercentile 99.0
    TimerPercentile 95.0
    TimerPercentile 90.0
    TimerCount true
  </Plugin>
EOT

  login_response=$(curl \
    -X POST \
    -d "user=$BLUEMIX_USERNAME&passwd=$BLUEMIX_PASSWORD&organization=Cloud%20Foundry%20Flintstone&space=performance-tests" \
    https://logmet.ng.bluemix.net/login)

  logging_token=$(echo $login_response | jq --raw-output .logging_token)
  space_id=$(echo $login_response | jq --raw-output .space_id)

  sed \
    -e "s/SPACE_ID/$space_id/g" \
    -e "s/LOGGING_TOKEN/$logging_token/g" \
    -e "s/GROUP_NAME/performance-tests/g" \
    /etc/collectd/collectd.conf.d/mt-metrics-writer.conf.sample \
    > /etc/collectd/collectd.conf.d/mt-metrics-writer.conf

  collectd
}

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
