
Here's how to create a new director in our Softlayer account:

Basically, follow instructions on https://github.com/gu-bin/docs-bosh/blob/master/content/init-softlayer.md#step-2-deploy--deploy-:

Make sure to use https://github.com/mattcui/bosh-deployment as `~/workspace/bosh-deployment` or check if https://github.com/cloudfoundry/bosh-deployment is more appropriate to use.

```shell
cd ~/workspace/bits-service-private-config/environments/softlayer/director
```

```shell
echo 'green' > active-director

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    --vars-store=$(cat active-director)-vars.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi.yml \
    -v director_name=bosh \
    -l <(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes) \
    -v internal_ip=director-$(cat active-director).bits.ams \
    -v sl_vm_domain=bits.ams \
    -v sl_vm_name_prefix=director-$(cat active-director) \
    -v sl_username=flintstone@cloudfoundry.org \
    -v sl_api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no) \
    -o ~/workspace/bits-service-ci/operations/use-softlayer-cpi-v35.yml \
    -o ~/workspace/bits-service-ci/operations/add-dummy-network-for-bosh.yml \
    -o ~/workspace/bits-service-ci/operations/add-etc-hosts-entry.yml \
    -o ~/workspace/bits-service-ci/operations/increase-max-speed.yml \
    > bosh-$(cat active-director).yml

sudo bosh create-env bosh-$(cat active-director).yml

direnv allow

bosh update-cloud-config ~/workspace/bits-service-private-config/environments/softlayer/cloud-config.yml
bosh update-runtime-config --name dns  ~/workspace/bosh-deployment/runtime-configs/dns.yml  --vars-store=runtime-bosh-dns-vars.yml
bosh update-runtime-config --name default-gateway  ~/workspace/bits-service-ci/runtime-config/add-default-route.yml
```

Note that this creates a director called `director-{green|blue}.bits.ams`. The idea is that we want to alternate between **blue** and **green**. There is no automatism yet, but it'll make it clear that we run with two directors simultaneously to avoid disruption.

Make sure to update all values in
* LastPass `ci-config` (IP, director VM name)
* `bits-service-ci/set-pipeline.sh` (vars yaml)
* `bits-service-ci/pipeline.yml` (hosts file)

Then run:
```shell
bits-service-ci/recreate-all-pipelines.sh
```

When everything works, **commit the new/updated files in `bits-service-private-config`**.
