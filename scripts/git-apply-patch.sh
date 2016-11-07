#!/bin/bash -ex

pwd
ls git-cf-release

pushd $1
curl $2 | git am
popd

mv $1 "$1-patched"
