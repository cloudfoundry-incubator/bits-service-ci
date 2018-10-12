#!/bin/bash -e

cd $(dirname $0)

github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)

fly -t flintstone login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)

fly -t flintstone set-pipeline -p ha-proxy-config-sync -c pipeline.yml \
  -v github-private-key="${github_ssh_key}" \
  -v ha_proxy_maschine="10.155.248.187"
fly -t flintstone expose-pipeline --pipeline ha-proxy-config-sync
