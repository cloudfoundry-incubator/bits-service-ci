#!/bin/bash -ex

pwd
ls git-cf-release

pushd $1
git am < $2
popd

mv $1 "$1-patched"
