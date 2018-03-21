#!/bin/bash -ex


cp -a state/. state-out
cp -a metrics/metrics.csv state-out

./ci-tasks/scripts/commit-file-if-changed.sh
