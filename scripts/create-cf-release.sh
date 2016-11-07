#!/bin/bash -ex

version=$(cat $VERSION_FILE)

cd $CF_RELEASE_DIR

bosh -n --parallel 10 sync blobs
bosh create release --force --name cf --with-tarball --version $version
mv dev_releases/cf/cf-*.tgz ../releases/
