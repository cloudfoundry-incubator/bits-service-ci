#!/bin/bash -e

for tarball_dir in $RELEASE_TARBALL_DIRS; do
   cat $tarball_dir/url
   echo
done
