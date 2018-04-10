#!/bin/bash -e

cd $(dirname $0)


../1-click/generate-bosh-lite-in-sl-manifest.sh blobstore-local-bosh-lite > /tmp/bosh-lite-in-sl.yml

../fly-login.sh flintstone

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p blobstore-local-bosh-lite \
  -c <(spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml recreate-blobstore-local-bosh-lite-every-morning.yml) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' /tmp/bosh-lite-in-sl.yml )" \
  -v bosh_lite_name='blobstore-local-bosh-lite' \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git'

rm -f /tmp/bosh-lite-in-sl.yml

fly -t flintstone expose-pipeline --pipeline blobstore-local-bosh-lite
