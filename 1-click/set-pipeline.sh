#!/bin/bash -e

full_name=$1-bosh-lite

cat > config.yml <<EOF
meta:
  bosh-lite-name: $full_name
  state-git-repo: git@github.com:cloudfoundry/bits-service-private-config.git
  cf-system-domain: $1.bosh-lite.dynamic-dns.net
EOF

spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml config.yml > pipeline.yml
rm config.yml

lpass show "Shared-Flintstone/Softlayer VLan IDs" --notes > vlanids.yml

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o operations/softlayer-cpi.yml \
    -v internal_ip=127.0.0.1 \
    -v softlayer_domain=flintstone.ams \
    -l vlanids.yml \
    -v softlayer_datacenter_name=ams03 \
    -v director_vm_prefix=$full_name \
    -v softlayer_username=flintstone@cloudfoundry.org \
    -v softlayer_api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no) \
    -v director_name=bosh \
    -o ~/workspace/bosh-deployment/bosh-lite.yml \
    -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
    -o operations/bosh-lite-network-default.yml \
    > bosh-generated.yml


fly -t flintstone login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password --sync=no)

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p $full_name \
  -c pipeline.yml \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' bosh-generated.yml )"

# Unpause so the check-resource call below works.
fly \
  -t flintstone \
  unpause-pipeline \
  -p $full_name \

# Hack to make this pinned version available in the pipeline (following Concourse's doc).
# We need this version, because `use-compiled-release.yml` depends on it.
fly -t flintstone check-resource -r $full_name/boshlite-stemcell -f version:3468.21

rm pipeline.yml