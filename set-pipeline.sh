#!/bin/bash

cd $(dirname $0)

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)
acceptance_ssh_key=$(lpass show "Shared-Flintstone"/Acceptance --notes)

fly \
  set-pipeline \
  -t flintstone \
  -p bits-service \
  -c pipeline.yml \
  -l config.yml \
  -v github-private-key="${github_ssh_key}" \
  -v acceptance-private-key="${acceptance_ssh_key}"
