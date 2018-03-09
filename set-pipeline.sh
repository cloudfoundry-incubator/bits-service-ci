#!/bin/bash -e

cd $(dirname $0)

target=flintstone

./fly-login.sh ${target}

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)
github_access_token=$(lpass show "Shared-Flintstone/Github Access Token" --password)
rubygems_api_key=$(lpass show "Shared-Flintstone"/flintstone@rubygems.org --notes)
bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username)
bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password)
slack_webhook=$(lpass show "Shared-Flintstone"/"Flintstone Slack Webhook" --password)
ibm_metrics_api_key=$(lpass show "Shared-Flintstone"/"IBM Metrics API Key" --password)
private_yml=$(lpass show "Shared-Flintstone/private.yml" --notes)
changeip_username=$(lpass show "Shared-Flintstone"/"changeip.com" --username)
changeip_password=$(lpass show "Shared-Flintstone"/"changeip.com" --password)
echo 'Installing overbook...'
set +e
wget --no-clobber https://github.com/petergtz/overbook/releases/download/0.1.0/overbook-macos -O /tmp/overbook
set -e
chmod +x /tmp/overbook
echo 'done'

/tmp/overbook -c pipeline.yml -t ci-tasks/tasks/generated/aggregate-committers-for-notification -r ci=ci-tasks > pipeline-overbooked.yml

fly \
  -t ${target} \
  set-pipeline \
  -p bits-service \
  -c pipeline-overbooked.yml \
  -l config.yml \
  -l <(lpass show "Shared-Flintstone"/dynu.com --notes) \
  -v github-private-key="${github_ssh_key}" \
  -v github-access-token="${github_access_token}" \
  -v rubygems-api-key="${rubygems_api_key}" \
  -v bluemix_cloudfoundry_username="${bluemix_cloudfoundry_username}" \
  -v bluemix_cloudfoundry_password="${bluemix_cloudfoundry_password}" \
  -v ibm_metrics_api_key="${ibm_metrics_api_key}" \
  -v sl-bosh-ca-cert="$(bosh int ~/workspace/bits-service-private-config/environments/softlayer/director/vars.yml --path /director_ssl/ca)" \
  -v bosh-ca-cert="$(<~/workspace/bosh-lite/ca/certs/ca.crt)" \
  -v slack-webhook="${slack_webhook}" \
  -v private-yml="${private_yml}" \
  -v changeip-username="${changeip_username}" \
  -v changeip-password="${changeip_password}"

rm -f pipeline-overbooked.yml
rm -f config.yml

fly -t ${target} expose-pipeline --pipeline bits-service
