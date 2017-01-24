#!/bin/bash -e

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)

fly -t flintstone login \
  --username $(lpass show --username "Shared-Flintstone"/"Flintstone Concourse") \
  --password $(lpass show --password "Shared-Flintstone"/"Flintstone Concourse")

fly -t flintstone set-pipeline \
  -p runtime-config \
  -c runtime-config/pipeline.yml \
  -l config.yml \
  -v github-private-key="${github_ssh_key}"

rm -f config.yml
