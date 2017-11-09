#!/bin/bash -ex

version=$(cat release-tarball/version)

# cp -v release-tarball/bits-service-*.tgz releases/bits-service-${version}.tgz

cd release-git-repo
bosh finalize-release ../release-tarball/*.tgz --version $version
git add .
git commit -am "Final release $version"

bosh create-release releases/bits-service/bits-service-$version.yml

cp release-git-repo bumped