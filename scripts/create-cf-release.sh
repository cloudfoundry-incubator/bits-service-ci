#!/bin/bash -ex

# assemble version as follows: <latest_final_release_version>.0.0+dev.<current_time_in_seconds>:
pushd $CF_RELEASE_DIR/releases
  version=$(ls cf-* | sort | tail -1 | sed "s/cf\-\(.*\)\.yml/\1/").0.0+dev.$(date +%s)
popd
echo $version > $VERSION_FILE

cd $CF_RELEASE_DIR

bosh -n --parallel 10 sync blobs
bosh create release --force --name cf --with-tarball --version $version
mv dev_releases/cf/cf-*.tgz ../releases/
