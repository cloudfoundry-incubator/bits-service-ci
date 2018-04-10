#!/bin/bash -e

cd $(dirname $0)
../fly-login.sh flintstone

pipeline_name="bitsgo-webdav"

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p ${pipeline_name} \
  -c <(spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml deploy-and-test-cf.yml) \
  -l <(lpass show "Shared-Flintstone"/ci-config --notes) \
  -v bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username) \
  -v bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password) \
  -v ibm_metrics_api_key=$(lpass show "Shared-Flintstone"/"IBM Metrics API Key" --password) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' <(../1-click/generate-bosh-lite-in-sl-manifest.sh ${pipeline_name}-bosh-lite) )" \
  -v bosh_lite_name=${pipeline_name}-bosh-lite \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git' \
  -v extra_args="-o cf-deployment/operations/experimental/bits-service.yml \
-o cf-deployment/operations/experimental/enable-bits-service-consul.yml \
-o cf-deployment/operations/experimental/bits-service-webdav.yml"

fly -t flintstone expose-pipeline --pipeline ${pipeline_name}
fly -t flintstone unpause-pipeline --pipeline ${pipeline_name}
