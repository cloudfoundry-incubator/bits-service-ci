#!/bin/bash -ex

cd $(dirname $0)/../../bits-service-deployment-manifest-generation-tools

export SPRUCE_FILE_BASE_PATH=../ci-tasks/manifests

./scripts/generate-test-standalone-manifest $BLOBSTORE_TYPE ../ci-tasks/manifests/bits-service-webdav-certs.yml

cp deployments/bits-service-release.yml ../manifests/manifest.yml

echo "Content of ../manifests/manifest.yml:"
cat ../manifests/manifest.yml
