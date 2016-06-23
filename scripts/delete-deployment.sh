#!/bin/bash -e

bosh -u x -p x target $BOSH_TARGET Lite
bosh login $BOSH_USERNAME $BOSH_PASSWORD

bosh -n delete deployment $DEPLOYMENT_NAME --force
