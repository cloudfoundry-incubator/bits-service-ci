#!/bin/bash -ex

cd $(dirname $0)/../../git-bits-service-ci

if [ -e "$VERSION_FILE" ]; then
  export VERSION=$(cat $VERSION_FILE)
  echo "Using VERSION=\"$VERSION\""
else
  echo "The \$VERSION_FILE \"$VERSION_FILE\" does not exist"
  exit 1
fi

sed \
  -e 's/name: cf$/name: <%= ENV\.fetch\('"'"'CF_DEPLOYMENT_NAME\'"'"') %>/g' \
  -e 's/REPLACE_WITH_DIRECTOR_ID/<%= `bosh status --uuid` %>/g' \
  -e 's/REPLACE_WITH_AZ/eu-west-1a/g' \
  -e 's/PASSWORD/"<%= ENV.fetch('"'"'CF_PASSWORD'"'"', '"'"'password'"'"') %>"/g' \
  -e 's/REPLACE_WITH_ELASTIC_IP/"<%= ENV.fetch('"'"'CF_PUBLIC_IP'"'"', '"'"'1.2.3.4'"'"') %>"/g' \
  -e 's/REPLACE_WITH_SYSTEM_DOMAIN/<%= ENV.fetch('"'"'CF_DOMAIN'"'"', '"'"'system.domain'"'"') %>/g' \
  -e 's/REPLACE_WITH_BOSH_STEMCELL_VERSION/latest/g' \
  -e '/REPLACE_WITH_SSL_CERT_AND_KEY/ {
    r ./manifests/ssl-certs
    d
  }' \
  ../git-cf-release/example_manifests/minimal-aws.yml \
> ./manifests/cf-aws-dynamic-sed.yml

# Place double quotes around ERB statements within square brackets
# to make spruce happy
# i.e. [<%= ... %>] --> ["<%= ... %>"]
sed -i \
  -e 's/\[<%=/\[\"<%=/g' -e 's/%>\]/%>"\]/g' \
  ./manifests/cf-aws-dynamic-sed.yml

echo "Content of ./manifests/cf-aws-dynamic-sed.yml:"
cat ./manifests/cf-aws-dynamic-sed.yml

spruce merge manifests/cf-aws-dynamic-sed.yml \
  ./manifests/bits-service.yml \
  ./manifests/bits-service-signing-users.yml \
  ./manifests/cf-release-minimal-aws-overlay.yml \
  ./manifests/acceptance-tests-job.yml \
  ../git-bits-service-release/templates/cc-blobstore-properties.yml \
  ./manifests/tweaks.yml \
  ./manifests/bits-network-aws.yml \
  ${MANIFEST_STUBS} \
> ./manifests/manifest-${VERSION}-no-syslog.yml

# Weave papertrail into every job
spruce merge \
  ./manifests/manifest-${VERSION}-no-syslog.yml \
  ./manifests/cf-remote-syslog.yml \
> ../manifests/manifest-${VERSION}.yml

# Replace '' with ' that somehow got introduced by spruce
# Remove double quotes around password in uaa
sed \
  -i \
  -e 's/'"'"''"'"'/'"'"'/g' \
  -e 's/"<%= ENV.fetch('"'"'CF_PASSWORD'"'"', '"'"'password'"'"') %>"/<%= ENV.fetch('"'"'CF_PASSWORD'"'"', '"'"'password'"'"') %>/g' \
  ../manifests/manifest-${VERSION}.yml

echo "Content of ../manifests/manifest-${VERSION}.yml:"
cat ../manifests/manifest-${VERSION}.yml
