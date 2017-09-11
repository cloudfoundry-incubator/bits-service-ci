#!/bin/bash -ex

# assemble version as follows: <latest_final_release_version>.0.0+dev.<date>.<time>.<commit_sha>:
pushd capi-release/releases
  version=$(ls -v capi/capi-* | tail -1 | sed "s/capi\/capi\-\(.*\)\.yml/\1/")+dev.$(date +"%Y-%m-%d.%H-%M-%S").$(git rev-parse HEAD | cut -c1-7)
popd
echo $version > $VERSION_FILE

cd capi-release

bosh2 -n sync-blobs --parallel 10
bosh2 create-release --force \
  --name capi \
  --version $version \
  --tarball=../releases/capi-$version.tgz
