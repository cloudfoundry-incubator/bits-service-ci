#!/bin/bash -ex

cd $(dirname $0)/../../git-bits-service-release

git config --global user.name "Pipeline"
git config --global user.email flintstone@cloudfoundry.org

git checkout master
pushd src/bits-service
  git checkout master
popd


git add src/bits-service
# TODO: Add bits-service commit messages to this commit message
git commit -m "Bump src/bits-service"

cd ..

cp -R git-bits-service-release/ git-bit-service-release-bumped
