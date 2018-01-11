#!/bin/bash -ex

function start_collectd {
  cat <<EOT > /etc/collectd/collectd.conf.d/ibmcloud-monitoring.sample

  LoadPlugin logfile
  <Plugin logfile>
    LogLevel "info"
    File "/var/log/collectd.log"
    Timestamp true
    PrintSeverity false
  </Plugin>

  <LoadPlugin IBMCloudMonitoring>
    FlushInterval 60
  </LoadPlugin>
  <Plugin IBMCloudMonitoring>
    <Endpoint "ng">
      Host "metrics.ng.bluemix.net"
      Port 9095
      ApiKey "API_KEY"
      SkipInternalPrefixForStatsd false
      RateCounter false
      ScopeId "s-SPACE_ID"
      Prefix "performance-tests."
    </Endpoint>
  </Plugin>
  LoadPlugin statsd
  <Plugin statsd>
    Host "127.0.0.1"
    DeleteCounters ture
    DeleteTimers false
    DeleteGauges false
    DeleteSets false
    TimerPercentile 99.0
    TimerPercentile 95.0
    TimerPercentile 90.0
    TimerCount true
  </Plugin>
EOT

  login_response=$(curl \
    -X POST \
    -d "user=$BLUEMIX_USERNAME&passwd=$BLUEMIX_PASSWORD&organization=Cloud%20Foundry%20Flintstone&space=performance-tests" \
    https://metrics.ng.bluemix.net/login)

  space_id=$(echo $login_response | jq --raw-output .space_id)

  if [ "$space_id" == "null" ]; then
    echo "Could not get space ID from https://metrics.ng.bluemix.net/login."
    exit 1
  fi

  sed \
    -e "s/SPACE_ID/$space_id/g" \
    -e "s/API_KEY/$METRICS_API_KEY/g" \
    -e "s/GROUP_NAME/performance-tests/g" \
    /etc/collectd/collectd.conf.d/ibmcloud-monitoring.sample \
    > /etc/collectd/collectd.conf.d/ibmcloud-monitoring.conf

  /etc/init.d/collectd start
}
