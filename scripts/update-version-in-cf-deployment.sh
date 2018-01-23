#!/bin/bash -e
# inputs:
# - name: release-version
# - name: ci-tasks
# - name: cf-deployment

# outputs:
# - name: cf-deplyoment-fork

export BITS_OPSFILE_TMP=/tmp/bits-service.yml
export BITS_OPSFILE=cf-deployment/operations/experimental/bits-service.yml
export VERSION=$(cat $VERSION_FILE)
# has to replaced with the output of create release
export SHA1=caa55a888046c2898063fabf0bb19c650ff9a618 

ruby ci-tasks/scripts/update_version_in_cf_deployment.rb
sed 's/"//g' $BITS_OPSFILE_TMP > $BITS_OPSFILE

pushd cf-deployment

  set +e
    git diff --exit-code
    exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "There are no changes to commit."
  else
    git config --global user.name "Pipeline"
    git config --global user.email flintstone@cloudfoundry.org

    git add src/bits-service
    scripts/staged_shortlog
    scripts/staged_shortlog | git commit -F -
  fi
popd

cp -r cf-deployment cf-deployment-fork/cf-deployment