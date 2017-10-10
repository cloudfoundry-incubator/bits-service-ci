#!/bin/bash -ex

(
  cd capi-release/src/cloud_controller_ng
  git remote add fork https://github.com/idev4u/cloud_controller_ng.git
  git fetch fork/master
  git cherry-pick 29d1797b2c4db73790a57abb90523a25c0770d27
)

prerelease_version=$(\
  gem search bits_service_client --pre --no-verbose \
  | sed 's/bits_service_client (\([^,]*\).*/\1/' \
)
sed \
  -i capi-release/src/cloud_controller_ng/Gemfile.lock \
  -e "s/bits_service_client .*/bits_service_client ($prerelease_version)/"

# (
#   cd git-cloud-controller-ng-fork; git cherry-pick 29d1797b2c4db73790a57abb90523a25c0770d27 --no-commit
# )

cp -a capi-release/. patched-capi-release
