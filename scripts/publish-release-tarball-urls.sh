#!/bin/bash -ex

for tarball_dir in $RELEASE_TARBALL_DIRS; do
   cat $tarball_dir/url
done
