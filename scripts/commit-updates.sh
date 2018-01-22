#!/bin/bash -ex

export REPO_DIR="$(readlink -f source-repo)"
export FILENAME='.'
export COMMIT_MESSAGE="Update opsfile with bits-service release $(cat release-version/version)"
./ci-tasks/scripts/commit-file-if-changed.sh
cp -r source-repo/. committed-repo/
