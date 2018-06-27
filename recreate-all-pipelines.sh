#!/bin/bash

cd $(dirname $0)

./set-pipeline.sh
./blobstore-local/set-pipeline.sh
./docker/set-pipeline.sh
./runtime-config/set-pipeline.sh
