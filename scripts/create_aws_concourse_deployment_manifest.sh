#!/bin/bash -ex

cd $(dirname $0)/..


spruce merge manifests/cf-aws.yml \
./manifests/tweaks.yml \
./manifests/bits-network-aws.yml \
./manifests/cf-aws-network-1.yml \
../bits-service-release/templates/cc-blobstore-properties.yml \
../bits-service-release/templates/s3.yml \
./manifests/enable-bits.yml \
> manifests/cf-aws-spruced.yml
