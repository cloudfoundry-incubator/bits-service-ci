#!/bin/bash -e

spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml $2 > pipeline.yml

fly -t flintstone login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)

changeip_username=$(lpass show "Shared-Flintstone"/"changeip.com" --username)
changeip_password=$(lpass show "Shared-Flintstone"/"changeip.com" --password)

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p $1 \
  -c pipeline.yml \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' /Users/pego/workspace/bits-service-private-config/environments/softlayer/director/bosh-warden-cpi.yml )" \
  -v changeip-username="${changeip_username}" \
  -v changeip-password="${changeip_password}"

# Hack to make this pinned version available in the pipeline (following Concourse's doc).
# We need this version, because `use-compiled-release.yml` depends on it.
fly -t flintstone check-resource -r $1/boshlite-stemcell -f version:3468.19

rm pipeline.yml