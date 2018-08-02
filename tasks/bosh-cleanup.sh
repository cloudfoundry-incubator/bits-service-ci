#!/bin/bash -ex

. ci-tasks/scripts/bosh-login.sh

bosh2 clean-up --all
