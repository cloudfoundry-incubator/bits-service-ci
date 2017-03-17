#!/bin/bash -e

cd $(dirname $0)/../../git-bits-service-release

version=$(cat $VERSION_FILE)
bosh --parallel 5 create release --force --name bits-service --with-tarball --version $version
mv dev_releases/bits-service/bits-service-*.tgz ../releases/
