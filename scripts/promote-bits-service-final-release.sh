#!/bin/bash -ex

version=$(cat release-version/version)
echo $PRIVATE_YML_CONTENT > release-git-repo/config/private.yml

cd release-git-repo
# bosh2 -n sync-blobs --parallel 10
bosh2 create-release --final --name bits-service --tarball ../release/bits-service-$version.tgz --version $version
git add .final_builds/ releases/
git commit -am "Final release $version"
