#!/bin/bash -e

../fly-login.sh flintstone

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p bitsgo-bosh-lite \
  -c <(spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml deploy-and-test-cf.yml) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' <(../1-click/generate-bosh-lite-in-sl-manifest.sh bitsgo-bosh-lite) )" \
  -v bosh_lite_name=bitsgo-bosh-lite \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git'
