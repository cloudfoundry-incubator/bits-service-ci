#!/bin/bash

cd $(dirname $0)

target=flintstone

fly login -t ${target} -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)
rubygems_api_key=$(lpass show "Shared-Flintstone"/flintstone@rubygems.org --notes)
acceptance_ssh_key=$(lpass show "Shared-Flintstone"/Acceptance --notes)

fly \
  set-pipeline \
  -t ${target} \
  -p bits-service \
  -c pipeline.yml \
  -l config.yml \
  -v github-private-key="${github_ssh_key}" \
  -v rubygems-api-key="${rubygems_api_key}" \
  -v acceptance-private-key="${acceptance_ssh_key}"

rm -f config.yml
