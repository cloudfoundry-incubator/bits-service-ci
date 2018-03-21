#!/bin/bash -ex

cp -a metrics/. metrics-committed

./ci-tasks/scripts/commit-file-if-changed.sh
