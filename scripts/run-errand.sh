#!/bin/bash -ex

date

bosh -u x -p x target $BOSH_TARGET
bosh login $BOSH_USERNAME $BOSH_PASSWORD

bosh download manifest ${DEPLOYMENT_NAME:-cf-warden} > manifest.yml
bosh deployment manifest.yml

bosh run errand $ERRAND_NAME $EXTRA_ARGS
