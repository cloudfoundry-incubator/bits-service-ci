
Here's how to create a new director in our Softlayer account:

Basically, follow instructions on https://github.com/gu-bin/docs-bosh/blob/master/content/init-softlayer.md#step-2-deploy--deploy-:

Make sure to use https://github.com/mattcui/bosh-deployment as `~/workspace/bosh-deployment` or check if https://github.com/cloudfoundry/bosh-deployment is more appropriate to use.

```shell
cd ~/workspace/bits-service-private-config/environments/softlayer/director
```

```shell
echo 'green' > active-director

### START CHANGES ENCALADA

# TODO , setup steps nicely to deploy director
# TODO, find bosh cli softlayer repo and latest version 
# TODO, also share insights on using cpi-dynamic

./create_vm_sl.sh -h * -d * -c * -m * -hb true -dc * -uv * -iv * -u * -k *  > director-state.json

# UPDATE THE bosh-green-state.jso, to use the CID and IP of the newly created VM
# Make sure you use the correct bosh cli with SL / IBM
# Using this one https://github.com/mattcui/bosh-deployment 

export BOSH_LOG_LEVEL=DEBUG
export BOSH_LOG_PATH=./run.log


echo 'green' > active-director
bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    --vars-store=$(cat active-director)-vars.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi-dynamic.yml \
    -o ~/workspace/bosh-deployment/misc/powerdns.yml \
    -o ~/workspace/bosh-deployment/jumpbox-user.yml \
    -v internal_ip=<IP_OF_NEW_VM> \
    -v sl_username=flintstone@cloudfoundry.org \
    -v sl_api_key=* \
    -v sl_datacenter=* \
    -v sl_vlan_private=* \
    -v sl_vlan_public=* \
    -v sl_vm_name_prefix=* \
    -v sl_vm_domain=* \
    -v dns_recursor_ip=8.8.8.8 \
    -v director_name=bosh \
    -o ~/workspace/in_house/bits-service-ci/operations/use-softlayer-cpi-v35.yml \
    > bosh-$(cat active-director)-new.yml

sudo bosh create-env --state bosh-green-state.json --vars-store green-vars.yml bosh-green-new.yml
direnv allow

# USE YOUR BOSH ENV

### END CHANGES ENCALADA
# sudo bosh create-env bosh-$(cat active-director)-new.yml
# direnv allow

bosh update-cloud-config ~/workspace/bits-service-private-config/environments/softlayer/cloud-config.yml
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
