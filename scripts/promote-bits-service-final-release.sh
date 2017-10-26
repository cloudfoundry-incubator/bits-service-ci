#!/bin/bash -ex

version=$(cat $VERSION_FILE)

#uploading /tmp/build/put/bits-service-release-tarball/bits-service-1.1.0-dev.1.tgz
# cp $TARBALL_DIR/bits-service-${tarbal-dev-version}.tgz ../releases/bits-service-$version.tgz --version $version
TGZ_COUNT=`ls $TARBALL_DIR/*.tgz | wc -l`
if [ ${TGZ_COUNT} -ne 1 ]
then
  printf "warning more then one tarball \n"
  printf "ls $TARBALL_DIR/*.tgz"
fi

cp -v $TARBALL_DIR/bits-service-*.tgz releases/bits-service-${version}.tgz
