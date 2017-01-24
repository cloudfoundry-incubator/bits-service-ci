#!/bin/bash -ex

# TODO: validate RELEASE_NAME

# assemble version as follows: <latest_final_release_version>.0.0+dev.<date>.<time>.<commit_sha>:
pushd release-repo/releases/$RELEASE_NAME
  version=$(ls $RELEASE_NAME-* | sort | tail -1 | sed "s/$RELEASE_NAME\-\(.*\)\.yml/\1/").0.0+dev.$(date +"%Y-%m-%d.%H-%M-%S").$(git rev-parse HEAD | cut -c1-7)
popd
echo $version > version/number

pushd release-repo
  bosh -n --parallel 10 sync blobs
  bosh -n create release --force --name $RELEASE_NAME --with-tarball --version $version
popd
mv release-repo/dev_releases/$RELEASE_NAME/$RELEASE_NAME-*.tgz release-tarball
