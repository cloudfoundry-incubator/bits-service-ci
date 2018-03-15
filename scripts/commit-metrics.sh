#!/bin/bash -ex

cp -r metrics-input/. metrics-committed/

mkdir -p metrics-committed/metrics
cp metrics/metrics.csv metrics-committed/metrics/

./ci-tasks/scripts/commit-file-if-changed.sh
