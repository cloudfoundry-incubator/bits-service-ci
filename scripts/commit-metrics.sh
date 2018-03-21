#!/bin/bash -ex


cp -a state/. state-out
./ci-tasks/scripts/commit-file-if-changed.sh
