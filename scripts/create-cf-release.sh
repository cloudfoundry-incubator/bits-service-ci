#!/bin/bash -ex

# assemble version as follows: <latest_final_release_version>.0.0+dev.<date>.<time>.<commit_sha>:
pushd $CF_RELEASE_DIR/releases
  version=$(ls cf-* | sort | tail -1 | sed "s/cf\-\(.*\)\.yml/\1/").0.0+dev.$(date +"%Y-%m-%d.%H-%M-%S").$(git rev-parse HEAD | cut -c1-7)
popd
echo $version > $VERSION_FILE

cd $CF_RELEASE_DIR

bosh -n --parallel 10 sync blobs
bosh create release --force --name cf --with-tarball --version $version
mv dev_releases/cf/cf-*.tgz ../releases/
