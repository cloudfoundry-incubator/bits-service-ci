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

ruby ci-tasks/scripts/update-version-in-cf-deployment.rb
sed 's/"//g' $BITS_OPSFILE_TMP > $BITS_OPSFILE