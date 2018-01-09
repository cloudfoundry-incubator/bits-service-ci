#!/bin/bash -e

login_response=$(curl \
  -X POST \
  -d "user=$BLUEMIX_USERNAME&passwd=$BLUEMIX_PASSWORD&organization=Cloud%20Foundry%20Flintstone&space=performance-tests" \
  https://metrics.ng.bluemix.net/login)

logging_token=$(echo $login_response | jq --raw-output .logging_token)
space_id=$(echo $login_response | jq --raw-output .space_id)
collectd_version=$(cat collectd-version/version)

sed \
  -e "s/COLLECTD_VERSION/$collectd_version/g" \
  -e "s/SPACE_ID/$space_id/g" \
  -e "s/LOGGING_TOKEN/$logging_token/g" \
  -e "s/GROUP_NAME/performance-tests/g" \
  ci-tasks/runtime-config/templates/collectd_addon.yml \
  > runtime-config/runtime-config.yml

cat runtime-config/runtime-config.yml
