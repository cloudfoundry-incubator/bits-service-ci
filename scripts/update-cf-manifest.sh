#!/bin/bash -e

cd $(dirname $0)/../../git-bits-service-ci

bosh -u x -p x target $BOSH_TARGET

if [[ ${IAAS} == "lite" ]]; then
  ../git-cf-release/scripts/generate_deployment_manifest \
      bosh-lite \
      <(echo "director_uuid: <%= %x[bosh status --uuid] %>") \
    > ./manifests/cf-lite.yml
fi

echo "Content of ./manifests/cf-${IAAS}.yml:"
cat ./manifests/cf-${IAAS}.yml

# spruce merge ./manifests/cf-${IAAS}.yml ./manifests/tweaks.yml ${MANIFEST_STUBS} > ../manifests/manifest.yml
spruce merge --go-patch ./manifests/cf-${IAAS}.yml ./manifests/tweaks.yml ./manifests/consul_cert.yml  ${MANIFEST_STUBS} > ../manifests/manifest.yml

# Apply ERB templates
TMP=../manifests/manifest.yml.tmp
erb ../manifests/manifest.yml > "$TMP"
mv ${TMP} ../manifests/manifest.yml

echo "Content of ../manifests/manifest.yml:"
cat ../manifests/manifest.yml
