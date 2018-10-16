
Here's how to create a new director in our Softlayer account:

Basically, follow instructions on https://github.com/gu-bin/docs-bosh/blob/master/content/init-softlayer.md#step-2-deploy--deploy-:

Make sure to use https://github.com/mattcui/bosh-deployment as `~/workspace/bosh-deployment` or check if https://github.com/cloudfoundry/bosh-deployment is more appropriate to use.

```shell
cd ~/workspace/bits-service-private-config/environments/softlayer/director

export IP=<Choose from portable IPs in subnet>

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    --vars-store=green-vars.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi.yml \
    -v director_name=bosh \
    -l <(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes) \
    -v internal_ip=${IP} \
    -v sl_vm_domain=bits.ams \
    -v sl_vm_name_prefix=director-green \
    -v sl_username=flintstone@cloudfoundry.org \
    -v sl_api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no) \
    > bosh-green.yml

sudo bosh create-env bosh-green.yml

bosh alias-env sl-green -e ${IP} --ca-cert <(bosh int blue-vars.yml --path /director_ssl/ca)
bosh -e sl-green login
bosh -e sl-green update-cloud-config ~/workspace/bits-service-private-config/environments/softlayer/cloud-config.blue.yml
```

Note that this creates a director called `director-green.bits.ams`. The idea is that we want to alternate between **blue** and **green**. There is no automatism yet, but it'll make it clear that we run with two directors simultaneously to avoid disruption.

Make sure to update all values in
* LastPass `ci-config` (IP, director VM name)
* `bits-service-private-config/environments/softlayer/cloud-config.green.yml` (IP)
* `bits-service-ci/set-pipeline.sh` (vars yaml)
* `bits-service-ci/pipeline.yml` (hosts file)

Then run:
```shell
bits-service-ci/recreate-all-pipelines.sh
```

When everything works, **commit the new/updated files in `bits-service-private-config`**.
