#!/bin/bash -e

# TODO this is almost identical to 1-click/set-pipeline. We should find a better way.

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi.yml \
    -l <(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes) \
    -v internal_ip=127.0.0.1 \
    -v sl_vm_domain=flintstone.ams \
    -v sl_vm_name_prefix=blobstore-local-bosh-lite \
    -v sl_username=flintstone@cloudfoundry.org \
    -v sl_api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no) \
    -v director_name=bosh \
    -o ~/workspace/bosh-deployment/bosh-lite.yml \
    -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
    -o ~/workspace/bosh-deployment/jumpbox-user.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/change-to-single-dynamic-network-named-default.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/change-cloud-provider-mbus-host.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/make-it-work-again-workaround.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/add-etc-hosts-entry.yml \
    > bosh-lite-in-sl.yml

fly -t flintstone login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password --sync=no)

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p blobstore-local-bosh-lite \
  -c ~/workspace/1-click-bosh-lite-pipeline/template.yml \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' bosh-lite-in-sl.yml )" \
  -v bosh_lite_name='blobstore-local-bosh-lite' \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git'
