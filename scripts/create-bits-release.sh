#!/bin/bash -ex

# Hack to fix an inconsitency in our setup:
# Semver knows pre-release as 1.2.3-dev.42 and similar. For bosh however, this is not 'latest', when there
# is also a 1.2.3. That breaks us, because we assumed so far always that 1.2.3-dev.42 > 1.2.3, which is not true.
# What is in fact true is that bosh treats 1.2.3+dev.42 > 1.2.3 (note the plus sign). This is also what bosh
# uses when creating a dev release without specifying the version.
# Since we seem to use a semver everywhere, this is an attempt to hack around it. It's unclear if it actually works.
# A long term fix would either use the plus-sign notation everywhere (which is not semver conform), or properly use
# semver version and expect everywhere that 1.2.3+dev.42 < 1.2.3.
sed -i -e 's/-dev/+dev/' $VERSION_FILE

version=$(cat $VERSION_FILE)${RELEASE_VERSION_SUFFIX}
cd git-bits-service-release

bosh2 -n sync-blobs --parallel 10
bosh2 create-release --force --name bits-service --tarball ../releases/bits-service-$version.tgz --version $version
