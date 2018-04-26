#!/bin/bash -e

cd $(dirname $0)

target=flintstone

./fly-login.sh ${target}

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

fly \
  -t ${target} \
  set-pipeline \
  -p bits-service \
  -c pipeline.yml \
  -l <(lpass show "Shared-Flintstone"/ci-config --notes) \
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
  -v changeip-password="${changeip_password}" \
  -v openstack_integration_test_config="$(lpass show 'Shared-Flintstone'/'contract integration test openstack' --notes)" \
  -v cos_integration_test_config="$(lpass show 'Shared-Flintstone'/'contract integration test cos' --notes)"

fly -t ${target} expose-pipeline --pipeline bits-service
