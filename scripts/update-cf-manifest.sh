#!/bin/bash -e

cd $(dirname $0)/../../git-bits-service-ci

if [[ ${IAAS} == "lite" ]]; then
  ../git-cf-release/scripts/generate_deployment_manifest \
      bosh-lite \
      <(echo "director_uuid: <%= %x[bosh status --uuid] %>") \
    > ./manifests/cf-lite.yml
fi

echo "Content of ./manifests/cf-${IAAS}.yml:"
cat ./manifests/cf-${IAAS}.yml

spruce merge ./manifests/cf-${IAAS}.yml ./manifests/tweaks.yml ${MANIFEST_STUBS} > ../manifests/manifest.yml

echo "Content of ../manifests/manifest.yml:"
cat ../manifests/manifest.yml
