#!/bin/bash -ex

version=$(cat $VERSION_FILE)
cd git-bits-service-release
echo "$PRIVATE_YML_CONTENT" > config/private.yml

bosh2 -n sync-blobs --parallel 10
bosh2 create-release --force --name bits-service --tarball ../releases/bits-service-$version.tgz --version $version
