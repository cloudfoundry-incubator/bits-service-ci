#!/bin/bash -e

cd $(dirname $0)

CLUSTER_NAME=${1:?"USAGE: set-pipeline.sh <cluster-name>"}

if [ "$(fly -t flintstone status)" != 'logged in successfully' ]; then
    fly -t flintstone login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)
fi

fly -t flintstone set-pipeline -p $CLUSTER_NAME -c pipeline.yml \
    -v ibmcloud-account='7e51fbb83371a0cb0fd553fab15aebf4' \
    -v ibmcloud-user=$(lpass show "Shared-Flintstone/Bluemix Cloud Foundry User" --username) \
    -v ibmcloud-password=$(lpass show "Shared-Flintstone/Bluemix Cloud Foundry User" --password) \
    -v cluster-name=$CLUSTER_NAME \
    -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes)" \
    -v eirini-release-branch=develop \
    -l ~/workspace/bits-service-private-config/kube-clusters/$CLUSTER_NAME/vars.yml

