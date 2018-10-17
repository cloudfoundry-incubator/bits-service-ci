#!/bin/bash -e

OBJECT_STORE_ACCESS_KEY=$(lpass show "Shared-Flintstone"/"Bluemix COS" --username)
OBJECT_STORE_SECRET=$(lpass show "Shared-Flintstone"/"Bluemix COS" --password)
GITHUB_SSH_KEY=$(lpass show "Shared-Flintstone"/Github --notes)

cd $(dirname $0)

# login to concourse-ci
../fly-login.sh flintstone

# set pipeline
fly -t flintstone set-pipeline \
    -p bits-docker-release \
    -c pipeline.yml \
    -l <(lpass show "Shared-Flintstone"/ci-config --notes) \
    -v github-private-key="${GITHUB_SSH_KEY}" \
    -v object-store-access-key=${OBJECT_STORE_ACCESS_KEY} \
    -v object-store-secret=${OBJECT_STORE_SECRET} \
    -v object-store-endpoint=s3.ams03.objectstorage.softlayer.net \
    -v object-store-region=ams03

