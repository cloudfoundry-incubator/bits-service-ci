# Instructions to deploy a new Concourse in Softlayer

## Update the cloud-config

```
bosh update cloud-config ~/workspace/bits-service-private-config/environments/softlayer/cloud_config.yml
```
## Upload a stemcell
```
bosh upload-stemcell https://s3.amazonaws.com/bosh-softlayer-cpi-stemcells/light-bosh-stemcell-315.41-softlayer-xen-ubuntu-xenial-go_agent.tgz
```

## Deploy
*Notice:* We have two directors (blue and green). Please ensure that you target the proper one and change the variable names accordingly i.e. `blue.vars` to `green.vars`

```bash
cd ~/workspace
git clone https://github.com/concourse/concourse-bosh-deployment.git
cd concourse-bosh-deployment/cluster
bosh -e sl-blue -d concourse deploy concourse.yml \
-l ../versions.yml \
-o ~/workspace/concourse-bosh-deployment/cluster/operations/container-placement-strategy-random.yml \
--vars-store ~/workspace/bits-service-private-config/environments/softlayer/concourse/concourse-blue-vars.yml \
-o ~/workspace/bits-service-ci/operations/add-concourse-containerization-workers.yml \
-o ~/workspace/bits-service-private-config/environments/softlayer/concourse/concourse-stemcell-bits-version.yml \
-o operations/scale.yml \
--var web_instances=2 \
--var worker_instances=5 \
-o operations/basic-auth.yml \
--var local_user.username=admin \
--var local_user.password=$(lpass show "Shared-Flintstone/Flintstone Concourse" --password) \
-o ~/workspace/bits-service-private-config/garden-dns-servers.yml \
--var external_url=https://ci.flintstone.cf.cloud.ibm.com \
--var network_name=default \
--var web_vm_type=concourse-server \
--var worker_vm_type=concourse-worker \
--var deployment_name=concourse \
-o operations/external-postgres.yml \
-o operations/external-postgres-tls.yml \
-l ~/workspace/bits-service-private-config/environments/softlayer/concourse/postgres_ca_cert.yml \
--var postgres_host=$(lpass show "Shared-Flintstone/Concourse compose database" --notes) \
--var postgres_port=17376 \
--var postgres_role=$(lpass show "Shared-Flintstone/Concourse compose database" --username)  \
--var postgres_password=$(lpass show "Shared-Flintstone/Concourse compose database" --password) \
--no-redact
```

### Concourse UI in browser using local `/etc/hosts`

Add an entry to your `/etc/hosts` using the `web/0` job's IP (get it from `bosh vms`) and a hostname ending in `.ci.cf-app.com`, such as `my-concourse.ci.cf-app.com`.

In the browser go to [https://my-concourse.ci.cf-app.com](https://my-concourse.ci.cf-app.com).

### Update HA Proxy config
After successful deployment please [update the HA proxy configuration accordingly](https://github.com/cloudfoundry-incubator/bits-service-ci/blob/master/docs/haproxy-setup.md#updating-the-haproxy-configuration)
