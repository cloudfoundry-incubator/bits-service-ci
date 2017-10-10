#!/bin/bash -ex
prerelease_version=$(\
  gem search bits_service_client --pre --no-verbose \
  | sed 's/bits_service_client (\([^,]*\).*/\1/' \
)
sed \
  -i capi-release/src/cloud_controller_ng/Gemfile.lock \
  -e "s/bits_service_client .*/bits_service_client ($prerelease_version)/"

cp -a capi-release/. patched-capi-release
