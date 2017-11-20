#!/bin/bash -ex

pushd fork-repo
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git remote add upstream ../upstream-repo
git remote -vvv
git fetch upstream
git rebase upstream/$BRANCH
popd

cp -a fork-repo/. synced-repo
