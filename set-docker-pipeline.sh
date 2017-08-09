#!/bin/bash

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml

target=flintstone
fly -t ${target} login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)

fly -t flintstone set-pipeline -p docker-images -c docker/pipeline.yml -l config.yml
fly -t flintstone expose-pipeline --pipeline docker-images

rm -f config.yml
