#!/bin/bash -e

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi-dynamic.yml  \
    -l <(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes) \
    -v internal_ip=$1.flintstone.ams \
    -v sl_vm_domain=flintstone.ams \
    -v sl_vm_name_prefix=$1 \
    -v sl_username=flintstone@cloudfoundry.org \
    -v sl_api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no) \
    -v director_name=bosh \
    -o ~/workspace/bosh-deployment/bosh-lite.yml \
    -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
    -o ~/workspace/bosh-deployment/jumpbox-user.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/add-etc-hosts-entry.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/increase-max-speed.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/disable-virtual-delete-vms.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/add-dummy-manual-network.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/use-softlayer-cpi-v35.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/use-localhost-blobstore.yml
