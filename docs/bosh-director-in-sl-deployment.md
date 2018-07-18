
Here's how to create a new director in our Softlayer account:


```shell
cd ~/workspace/bits-service-private-config/environments/softlayer/director

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    --vars-store=blue-vars.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi-dynamic.yml \
    -v director_name=bosh \
    -l <(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes) \
    -v internal_ip=director-blue.flinstone.ams \
    -v sl_vm_domain=flinstone.ams \
    -v sl_vm_name_prefix=director-blue \
    -v sl_username=flintstone@cloudfoundry.org \
    -v sl_api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no) \
    -o ~/workspace/bosh-deployment/jumpbox-user.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/add-etc-hosts-entry.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/increase-max-speed.yml \
    > bosh-blue.yml

sudo bosh create-env bosh-blue.yml

bosh alias-env sl-blue -e director-blue.flinstone.ams --ca-cert <(bosh int blue-vars.yml --path /director_ssl/ca)
```

Note that this creates a director called `director-blue.flinstone.ams`. The idea is that we want to alternate between **blue** and **green**. There is no automatism yet, but it'll make it clear that we run with two directors simultaneously to avoid disruption.

Make sure to update all values in
* LastPass `ci-config` (IP, director VM name)
* `bits-service-private-config/environments/softlayer/cloud-config.blue.yml` (IP)
* `bits-service-ci/set-pipeline.sh` (vars yaml)
* `bits-service-ci/pipeline.yml` (hosts file)

Then run:
```shell
bits-service-ci/recreate-all-pipelines.sh
```

When everything works, **commit the new/updated files in `bits-service-private-config`**.
