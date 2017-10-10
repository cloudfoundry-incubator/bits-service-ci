#!/bin/bash -ex

(
  cd capi-release/src/cloud_controller_ng
  git remote add -f fork/master https://github.com/idev4u/cloud_controller_ng.git
  git cherry-pick -m HEAD 29d1797b2c4db73790a57abb90523a25c0770d27
  git add bosh/jobs/cloud_controller_ng/*
  git commit m "Add BitsService TLS ca_cert"
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
