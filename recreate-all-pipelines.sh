#!/bin/bash -ex

cd $(dirname $0)

./set-pipeline.sh
./migration-boshlites/set-pipeline.sh
./docker/set-pipeline.sh
./runtime-config/set-pipeline.sh
