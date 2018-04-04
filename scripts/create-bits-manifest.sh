#!/bin/bash -ex

cd $(dirname $0)/../../bits-service-deployment-manifest-generation-tools

export SPRUCE_FILE_BASE_PATH=../ci-tasks/manifests

./scripts/generate-test-standalone-manifest $BLOBSTORE_TYPE ../ci-tasks/manifests/bits-service-webdav-certs.yml $ADDITIONAL_ARGS

cp deployments/bits-service-release.yml ../manifests/manifest.yml

echo "Content of ../manifests/manifest.yml:"
cat ../manifests/manifest.yml

REPO_DIR=../bits-service-private-config \
FILENAME=environments/softlayer/deployment-vars-${DEPLOYMENT_NAME}.yml \
COMMIT_MESSAGE="Update ${ENVIRONMENT_NAME} deployment vars for ${DEPLOYMENT_NAME}" \
../ci-tasks/scripts/commit-file-if-changed.sh

cp -r ../bits-service-private-config ../updated/bits-service-private-config
