#!/bin/bash -e
./fly-login.sh flintstone
fly -t flintstone set-pipeline -p bits-docker-release -c pipeline.yml -l <(lpass show "Shared-Flintstone"/ci-config --notes)