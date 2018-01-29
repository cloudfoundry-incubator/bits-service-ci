#!/bin/bash -ex

version=$(cat release-version/version)

pushd source-repo
  set +e
    git diff --exit-code
    exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "There are no changes to commit."
  else
    git config --global user.name "Pipeline"
    git config --global user.email flintstone@cloudfoundry.org

    git add .
    git commit -m "Update opsfile with bits-service release $version"
  fi
popd

cp -r source-repo/. committed-repo/
