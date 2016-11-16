#!/bin/bash -ex

cd $CF_RELEASE_DIR

# assemble version as follows: <latest_final_release_version>+dev.<current_time_in_seconds>:
version="$(ls releases/cf-* | sort | tail -1 | sed 's/releases\/cf\-\(.*\)\.yml/\1/')+dev.$(date +%s)"
echo $version > $VERSION_FILE

bosh -n --parallel 10 sync blobs
bosh create release --force --name cf --with-tarball --version $version
mv dev_releases/cf/cf-*.tgz ../releases/
