#!/bin/bash

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml

fly -t flintstone set-pipeline -p docker-images -c docker/pipeline.yml -l config.yml
fly -t flintstone expose-pipeline --pipeline docker-images

rm -f config.yml
