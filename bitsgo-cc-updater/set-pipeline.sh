#!/bin/bash -e

cd $(dirname $0)


../1-click/generate-bosh-lite-in-sl-manifest.sh cc-updater-bosh-lite > /tmp/bosh-lite-in-sl.yml

../fly-login.sh flintstone

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p cc-updater-test \
  -c <(spruce merge ~/workspace/1-click-bosh-lite-pipeline/template.yml ../1-click/recreate-bosh-lite-every-morning.yml run-cc-updater-tests.yml) \
  -l <(lpass show "Shared-Flintstone"/ci-config --notes) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' /tmp/bosh-lite-in-sl.yml )" \
  -v bosh_lite_name='cc-updater-bosh-lite' \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git' \
  -v sl_vm_domain='flintstone.ams'

rm -f /tmp/bosh-lite-in-sl.yml

fly -t flintstone expose-pipeline --pipeline cc-updater-test
