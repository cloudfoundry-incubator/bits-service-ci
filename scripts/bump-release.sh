#!/bin/bash -ex

pushd git-sub-repo
  SOURCE_MASTER_SHA=$(git rev-parse HEAD)
popd
pushd git-repo
  pushd $SUB_MODULE_PATH
    git fetch
    git checkout $SOURCE_MASTER_SHA
  popd

  set +e
    git diff --exit-code
    exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "There are no changes to commit."
  else
    git config --global user.name "Pipeline"
    git config --global user.email flintstone@cloudfoundry.org

    git add $SUB_MODULE_PATH
    scripts/staged_shortlog
    scripts/staged_shortlog | git commit -F -
  fi
popd

cp -r git-repo bumped/git-repo
