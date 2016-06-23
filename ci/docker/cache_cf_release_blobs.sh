#!/bin/bash

git clone https://github.com/cloudfoundry/cf-release.git

cd cf-release
git checkout v237
git submodule update --init --recursive

bosh create release --with-tarball --name cf-release

cd ..
rm -rf cf-release
