#!/bin/bash -ex

DEPLOYMENT_NAME=${DEPLOYMENT_NAME:?DEPLOYMENT_NAME missing}

cd git-bits-service-ci-metadata

EVENT_DIR="events/$DEPLOYMENT_NAME"
mkdir -p "$EVENT_DIR"

date | tee "$EVENT_DIR"/deployment-deleted

git config --global user.name "Pipeline"
git config --global user.email flintstone@cloudfoundry.org

git pull
git add "$EVENT_DIR"/deployment-deleted
git commit -m "Deployment $DEPLOYMENT_NAME was deleted"
