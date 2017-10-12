#!/bin/bash -ex

pushd $SUBMODULE
    curl $PATCH_URL | git apply
    git commit -am "Apply patch $PATCH_URL"
popd
pushd git_repo
    git commit -am "Bump submodule"
popd    

cp -a git_repo/. patched_repo
