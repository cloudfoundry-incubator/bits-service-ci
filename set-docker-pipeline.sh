#!/bin/bash

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
fly -t flintstone set-pipeline -p docker-images -c docker/pipeline.yml -l config.yml

rm -f config.yml
