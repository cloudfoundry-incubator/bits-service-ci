#!/bin/bash -e

cd $(dirname $0)

github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)
bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username)
bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password)
softlayer_bosh_username=$(lpass show "Shared-Flintstone"/"Flintstone BOSH director" --username)
softlayer_bosh_password=$(lpass show "Shared-Flintstone"/"Flintstone BOSH director" --password)
ibm_metrics_api_key=$(lpass show "Shared-Flintstone"/"IBM Metrics API Key" --password)

fly -t flintstone login \
  --username $(lpass show --username "Shared-Flintstone"/"Flintstone Concourse") \
  --password $(lpass show --password "Shared-Flintstone"/"Flintstone Concourse")

fly -t flintstone set-pipeline \
  -p runtime-config \
  -c pipeline.yml \
  -l <(lpass show "Shared-Flintstone"/ci-config --notes) \
  -v github-private-key="${github_ssh_key}" \
  -v bluemix_cloudfoundry_username="${bluemix_cloudfoundry_username}" \
  -v bluemix_cloudfoundry_password="${bluemix_cloudfoundry_password}" \
  -v ibm_metrics_api_key="${ibm_metrics_api_key}" \
  -v softlayer-bosh-username="${softlayer_bosh_username}" \
  -v softlayer-bosh-password="${softlayer_bosh_password}"

fly -t flintstone expose-pipeline --pipeline runtime-config
