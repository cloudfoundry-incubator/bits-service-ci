#!/bin/bash -ex

# TODO: validate RELEASE_NAME

# assemble version as follows: <latest_final_release_version>.0.0+dev.<date>.<time>.<commit_sha>:
pushd release-repo/releases/$RELEASE_NAME
  version=$(ls $RELEASE_NAME-* | sort | tail -1 | sed "s/$RELEASE_NAME\-\(.*\)\.yml/\1/").0.0+dev.$(date +"%Y-%m-%d.%H-%M-%S").$(git rev-parse HEAD | cut -c1-7)
popd
echo $version > version/number

pushd release-repo
  bosh2 -n sync-blobs --parallel 10
  bosh2 -n create-release --force --name $RELEASE_NAME --tarball ../release-tarball/$RELEASE_NAME-$version.tgz  --version $version
popd
