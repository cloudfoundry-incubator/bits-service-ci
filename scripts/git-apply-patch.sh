#!/bin/bash -ex

pushd $GIT_REPO_DIR
curl $PATCH_URL | git am
popd

cp -a $INPUT_DIR/* $OUTPUT_DIR/
