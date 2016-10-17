#!/bin/bash -e

cd $(dirname $0)/../../bits-service-deployment-manifest-generation-tools

if [ -e "$VERSION_FILE" ]; then
  export VERSION=$(cat $VERSION_FILE)
  echo "Using VERSION=\"$VERSION\""
else
  echo "The \$VERSION_FILE \"$VERSION_FILE\" does not exist"
  exit 1
fi

bosh -u x -p x target $BOSH_TARGET Lite
bosh login $BOSH_USERNAME $BOSH_PASSWORD

if [ -z "$BLOBSTORE_TYPE" ]
then
  >&2 echo "Please provide $BLOBSTORE_TYPE"
  exit 1
else
  ./scripts/generate-test-bosh-lite-manifest \
    ./templates/$BLOBSTORE_TYPE.yml \
    ../git-bits-service-ci/manifests/bits-release-network-$BLOBSTORE_TYPE.yml
fi

cp deployments/bits-service-release.yml ../manifests/manifest-$VERSION.yml
cp deployments/bits-service-release.yml ../manifests/manifest.yml
