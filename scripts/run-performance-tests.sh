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

echo "Insert performance test here"

echo "performance-test-run:1|c" | nc -u -w0 127.0.0.1 8125
