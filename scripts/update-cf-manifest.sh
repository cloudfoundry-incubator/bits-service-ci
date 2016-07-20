#!/bin/bash -e

cd $(dirname $0)/../../git-bits-service-ci

if [ -e "$VERSION_FILE" ]; then
  export VERSION=$(cat $VERSION_FILE)
  echo "Using VERSION=\"$VERSION\""
else
  echo "The \$VERSION_FILE \"$VERSION_FILE\" does not exist"
  exit 1
fi

if [[ ${IAAS} == "lite" ]]; then
  ../git-cf-release/scripts/generate_deployment_manifest \
      bosh-lite \
      <(echo "director_uuid: <%= %x[bosh status --uuid] %>") \
    > ./manifests/cf-lite.yml
fi

spruce merge ./manifests/cf-${IAAS}.yml ./manifests/tweaks.yml ${MANIFEST_STUBS} > ../manifests/manifest-${VERSION}.yml
