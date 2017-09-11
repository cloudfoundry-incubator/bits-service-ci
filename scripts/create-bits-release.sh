#!/bin/bash -e

version=$(cat $VERSION_FILE)
cd git-bits-service-release

bosh --parallel 5 create release --force --name bits-service --with-tarball --version $version
mv dev_releases/bits-service/bits-service-*.tgz ../releases/
