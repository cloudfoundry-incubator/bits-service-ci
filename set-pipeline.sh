#!/bin/bash -e

cd $(dirname $0)

target=flintstone

fly -t ${target} login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)
rubygems_api_key=$(lpass show "Shared-Flintstone"/flintstone@rubygems.org --notes)
bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username)
bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password)

fly \
  -t ${target} \
  set-pipeline \
  -p bits-service \
  -c pipeline.yml \
  -l config.yml \
  -v github-private-key="${github_ssh_key}" \
  -v rubygems-api-key="${rubygems_api_key}" \
  -v bluemix_cloudfoundry_username="${bluemix_cloudfoundry_username}" \
  -v bluemix_cloudfoundry_password="${bluemix_cloudfoundry_password}"

rm -f config.yml

fly -t ${target} expose-pipeline --pipeline bits-service
fly -t ${target} expose-pipeline --pipeline docker-images
