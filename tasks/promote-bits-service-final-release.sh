#!/bin/bash -ex

version=$(cat release-version/version)
echo "$PRIVATE_YML_CONTENT" > release-git-repo/config/private.yml

pushd release-git-repo
    bosh2 -n sync-blobs --parallel 10
    bosh2 create-release --final --name bits-service --tarball ../release-tarball/bits-service-$version.tgz --version $version
    git add .
    git commit -am "Final release $version"
popd

cp -a release-git-repo/. release-git-repo-final
