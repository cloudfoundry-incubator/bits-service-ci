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

fly -t flintstone login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password --sync=no)

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p $full_name \
  -c pipeline.yml \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' $HOME/workspace/bits-service-private-config/environments/softlayer/director/bosh-warden-cpi.yml )"

# Unpause so the check-resource call below works.
fly \
  -t flintstone \
  unpause-pipeline \
  -p $full_name \

# Hack to make this pinned version available in the pipeline (following Concourse's doc).
# We need this version, because `use-compiled-release.yml` depends on it.
fly -t flintstone check-resource -r $full_name/boshlite-stemcell -f version:3468.21

rm pipeline.yml