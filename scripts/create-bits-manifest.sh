#!/bin/bash -ex

cd $(dirname $0)/../../bits-service-deployment-manifest-generation-tools

bosh -u x -p x target $BOSH_TARGET
bosh login $BOSH_USERNAME $BOSH_PASSWORD

export SPRUCE_FILE_BASE_PATH=../ci-tasks/manifests

./scripts/generate-test-standalone-manifest $BLOBSTORE_TYPE ../ci-tasks/manifests/bits-service-webdav-certs.yml

cp deployments/bits-service-release.yml ../manifests/manifest.yml

echo "Content of ../manifests/manifest.yml:"
cat ../manifests/manifest.yml
