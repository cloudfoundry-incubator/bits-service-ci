#!/bin/bash -e

cd $(dirname $0)/../../git-bits-service-ci

if [ -e "$VERSION_FILE" ]; then
  export VERSION=$(cat $VERSION_FILE)
  echo "Using VERSION=\"$VERSION\""
else
  echo "The \$VERSION_FILE \"$VERSION_FILE\" does not exist"
  exit 1
fi

spruce merge ./manifests/cf-${IAAS}.yml ./manifests/tweaks.yml ${MANIFEST_STUBS} > ../manifests/manifest-${VERSION}.yml
