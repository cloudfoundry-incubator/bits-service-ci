#!/bin/bash -e

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi.yml \
    -l <(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes) \
    -v internal_ip=127.0.0.1 \
    -v sl_vm_domain=flintstone.ams \
    -v sl_vm_name_prefix=$1 \
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
