#!/bin/bash -e

full_name=$1-bosh-lite

../fly-login.sh flintstone

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p $full_name \
  -c <(spruce merge ~/workspace/1-click-bosh-lite-pipeline/template.yml ~/workspace/1-click-bosh-lite-pipeline/deploy-and-test-cf.yml) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' <(./generate-bosh-lite-in-sl-manifest.sh $full_name) )" \
  -v bosh_lite_name=$full_name \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git' \
  -v sl_vm_domain=flintstone.ams
# Unpause so the check-resource call below works.
fly \
  -t flintstone \
  unpause-pipeline \
  -p $full_name \
