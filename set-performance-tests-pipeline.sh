#!/bin/bash -e

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)
bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username)
bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password)

fly -t flintstone login \
  --username $(lpass show --username "Shared-Flintstone"/"Flintstone Concourse") \
  --password $(lpass show --password "Shared-Flintstone"/"Flintstone Concourse")

fly -t flintstone set-pipeline \
  -p performance-tests \
  -c performance-tests/pipeline.yml \
  -l config.yml \
  -v github-private-key="${github_ssh_key}" \
  -v bluemix_cloudfoundry_username="${bluemix_cloudfoundry_username}" \
  -v bluemix_cloudfoundry_password="${bluemix_cloudfoundry_password}"

rm -f config.yml
