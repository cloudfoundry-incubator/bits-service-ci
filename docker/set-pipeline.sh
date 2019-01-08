#!/bin/bash -e

cd $(dirname $0)

fly -t flintstone login -c https://ci.flintstone.cf.cloud.ibm.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)

fly -t flintstone set-pipeline -p docker-images -c pipeline.yml -l <(lpass show "Shared-Flintstone"/ci-config --notes)
fly -t flintstone expose-pipeline --pipeline docker-images
