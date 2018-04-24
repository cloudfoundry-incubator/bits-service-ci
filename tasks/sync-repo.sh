#!/bin/bash -ex

if [ -z $FORK_BRANCH ]; then
    FORK_BRANCH=$BRANCH
fi

if [ -z $UPSTREAM_BRANCH ]; then
    UPSTREAM_BRANCH=$BRANCH
fi

pushd fork-repo
git checkout $FORK_BRANCH
git remote add upstream ../upstream-repo
git remote -vvv
git fetch upstream
git rebase upstream/$UPSTREAM_BRANCH
popd

cp -a fork-repo/. synced-repo
