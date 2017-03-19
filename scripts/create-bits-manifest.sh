#!/bin/bash -ex

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

export SPRUCE_FILE_BASE_PATH=../ci-tasks/manifests

./scripts/generate-test-standalone-manifest $BLOBSTORE_TYPE ../ci-tasks/manifests/bits-service-webdav-certs.yml

cp deployments/bits-service-release.yml ../manifests/manifest-$VERSION.yml
cp deployments/bits-service-release.yml ../manifests/manifest.yml

echo "Content of ../manifests/manifest.yml:"
cat ../manifests/manifest.yml
