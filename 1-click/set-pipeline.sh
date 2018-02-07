#!/bin/bash -e

full_name=$1-bosh-lite

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi.yml \
    -l <(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes) \
    -v internal_ip=127.0.0.1 \
    -v sl_vm_domain=flintstone.ams \
    -v sl_vm_name_prefix=$full_name \
    -v sl_username=flintstone@cloudfoundry.org \
    -v sl_api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no) \
    -v director_name=bosh \
    -o ~/workspace/bosh-deployment/bosh-lite.yml \
    -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/change-to-single-dynamic-network-named-default.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/change-cloud-provider-mbus-host.yml \
    -o ~/workspace/1-click-bosh-lite-pipeline/operations/make-it-work-again-workaround.yml \
    > bosh-lite-in-sl.yml

fly -t flintstone login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password --sync=no)

cat > config.yml <<EOF
meta:
  bosh-lite-name: $full_name
  state-git-repo: git@github.com:cloudfoundry/bits-service-private-config.git
  cf-system-domain: $1.bosh-lite.dynamic-dns.net
EOF

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p $full_name \
  -c <(spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml config.yml) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' bosh-lite-in-sl.yml )"

rm config.yml bosh-lite-in-sl.yml

# Unpause so the check-resource call below works.
fly \
  -t flintstone \
  unpause-pipeline \
  -p $full_name \

# Hack to make this pinned version available in the pipeline (following Concourse's doc).
# We need this version, because `use-compiled-release.yml` depends on it.
fly -t flintstone check-resource -r $full_name/boshlite-stemcell -f version:3468.21
