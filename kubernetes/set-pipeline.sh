#!/bin/bash -e

cd $(dirname $0)

../1-klick/set-pipeline.sh bits-marry-eirini

fly -t flintstone expose-pipeline --pipeline bits-marry-eirini

