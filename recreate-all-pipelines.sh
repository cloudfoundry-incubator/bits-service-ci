#!/bin/bash

cd $(dirname $0)

./set-pipeline.sh
./bitsgo/set-pipeline.sh webdav
./bitsgo/set-pipeline.sh aws-s3
./bitsgo/set-pipeline.sh cos-s3
./bitsgo/set-pipeline.sh local
./bitsgo/set-pipeline.sh azure
./bitsgo/set-pipeline.sh openstack
./bitsgo-cc-updater/set-pipeline.sh
./blobstore-local/set-pipeline.sh
./docker/set-pipeline.sh
./runtime-config/set-pipeline.sh
