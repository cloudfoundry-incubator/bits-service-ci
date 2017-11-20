#!/bin/bash -ex

pushd fork-repo
git co $BRANCH
git remote add upstream ../upstream-repo
git remote -vvv
git fetch upstream
git rebase upstream/$BRANCH
popd

cp -a fork-repo/. synced-repo
