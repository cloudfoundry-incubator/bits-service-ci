#!/bin/bash -ex

pushd git-cf-release
  cf_release_sha=$(git rev-parse HEAD)
popd

echo Determining additional releases compatible with cf-release "$cf_release_sha"

pushd ci-tasks
  diego_version=$(./scripts/diego_cf_compatibility "$cf_release_sha" --diego)
  garden_runc_version=$(./scripts/diego_cf_compatibility "$cf_release_sha" --garden)
  cflinuxfs2_rootfs_version=$(./scripts/diego_cf_compatibility "$cf_release_sha" --cflinux)
popd

bosh -u x -p x target $BOSH_TARGET
bosh login $BOSH_USERNAME $BOSH_PASSWORD

bosh upload release https://bosh.io/d/github.com/cloudfoundry/diego-release?v=$diego_version
bosh upload release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release?v=$garden_runc_version
bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-release?v=$cflinuxfs2_rootfs_version
