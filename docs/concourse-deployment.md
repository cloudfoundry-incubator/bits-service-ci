# Instructions to deploy a new Concourse in Softlayer

## Update the cloud-config

Use [cloud_config.yml](cloud_config.yml) and update the cloud-config:

```
bosh update cloud-config cloud_config.yml
```
Upload the a specific mandatory SL stemmcell for concourse
```
bosh upload-stemcell --sha1 b3a21364351058771236b825ef65102962bf1def \
  https://bosh.io/d/stemcells/bosh-softlayer-xen-ubuntu-trusty-go_agent?v=3468.22
```

## Deploy

```bash
cd ~/workspace
git clone https://github.com/concourse/concourse-deployment.git
cd concourse-deployment/cluster
bosh -e sl -d concourse deploy concourse.yml \
  -l ../versions.yml \
  --vars-store ~/workspace/bits-service-private-config/environments/softlayer/concourse/concourse-vars.yml \
  -o ~/workspace/bits-service-private-config/environments/softlayer/concourse/concourse-stemcell-bits-version.yml \
  -o operations/scale.yml \
  --var web_instances=2 \
  --var worker_instances=5 \
  -o operations/basic-auth.yml \
  --var atc_basic_auth.username=admin \
  --var atc_basic_auth.password=$(lpass show "Shared-Flintstone/Flintstone Concourse" --password) \
  -o ~/workspace/bits-service-private-config/garden-dns-servers.yml \
  --var external_url=https://flintstone.ci.cf-app.com \
  --var network_name=default \
  --var web_vm_type=concourse-server \
  --var db_vm_type=concourse-server \
  --var db_persistent_disk_type=200GB \
  --var worker_vm_type=concourse-worker \
  --var deployment_name=concourse \
  --no-redact
```

### Concourse UI in browser using local `/etc/hosts`

Add an entry to your `/etc/hosts` using the `web/0` job's IP (get it from `bosh vms`) and a hostname ending in `.ci.cf-app.com`, such as `my-concourse.ci.cf-app.com`.

In the browser go to [https://my-concourse.ci.cf-app.com](https://my-concourse.ci.cf-app.com).
