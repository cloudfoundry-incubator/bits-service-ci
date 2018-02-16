#!/bin/bash -e

full_name=$1-bosh-lite

./generate-bosh-lite-in-sl-manifest.sh $full_name > bosh-lite-in-sl.yml

../fly-login.sh flintstone

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p $full_name \
  -c <(spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml ~/workspace/1-click-bosh-lite-pipeline/deploy-and-test-cf.yml) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' bosh-lite-in-sl.yml )" \
  -v bosh_lite_name=$full_name \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git' \
  -v cf_system_domain="$full_name.freeddns.org"

# Unpause so the check-resource call below works.
fly \
  -t flintstone \
  unpause-pipeline \
  -p $full_name \

# Hack to make this pinned version available in the pipeline (following Concourse's doc).
# We need this version, because `use-compiled-release.yml` depends on it.
# UNCOMMENT when using ~/workspace/1-click-bosh-lite-pipeline/deploy-and-test-cf.yml
fly -t flintstone check-resource -r $full_name/boshlite-stemcell -f version:3541.2
