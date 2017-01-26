#!/bin/bash -ex

pushd $INPUT_DIR
    prerelease_version=$(gem search bits_service_client --pre --no-verbose | sed 's/bits_service_client (\([^,]*\).*/\1/')
    sed -i src/capi-release/src/cloud_controller_ng/Gemfile.lock -e "s/bits_service_client .*/bits_service_client ($prerelease_version)/"
popd

cp -a $INPUT_DIR/. $OUTPUT_DIR
