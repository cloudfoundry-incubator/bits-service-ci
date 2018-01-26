#!/bin/bash -e

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
    scripts/staged_shortlog
    scripts/staged_shortlog | git commit -F -
  fi
popd

cp -r source-repo updated-repo/source-repo
