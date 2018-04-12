#!/bin/bash -e

cd $(dirname $0)
../fly-login.sh flintstone

pipeline_name="bitsgo-$1"
if [ "$1" == "aws-s3" ]; then
  export blobstore_access_key_id=$(lpass show "Shared-Flintstone"/"ci-bitsgo-s3" --username)
  export blobstore_secret_access_key=$(lpass show "Shared-Flintstone"/"ci-bitsgo-s3" --password)
  export aws_region=eu-west-1
  export resource_directory_key=bits-cf-app-com-blobs
  export buildpack_directory_key=bits-cf-app-com-blobs
  export droplet_directory_key=bits-cf-app-com-blobs
  export app_package_directory_key=bits-cf-app-com-blobs

elif [ "$1" == "cos-s3" ]; then
  export blobstore_access_key_id=$(lpass show "Shared-Flintstone"/"Bluemix COS" --username)
  export blobstore_secret_access_key=$(lpass show "Shared-Flintstone"/"Bluemix COS" --password)
  export aws_region=eu-geo
  export aws_signature_version=4
  export cos_ssl_version=TLSv1_2
  export cos_scheme=http
  export cos_host=s3.eu-geo.objectstorage.softlayer.net
  export resource_directory_key=cf-bits
  export buildpack_directory_key=cf-bits
  export droplet_directory_key=cf-bits
  export app_package_directory_key=cf-bits
fi

eval "echo \"$(cat $1.yml)\"" > extra_args.yml

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p ${pipeline_name} \
  -c <(spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml deploy-and-test-cf.yml extra_args.yml) \
  -l <(lpass show "Shared-Flintstone"/ci-config --notes) \
  -v bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username) \
  -v bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password) \
  -v ibm_metrics_api_key=$(lpass show "Shared-Flintstone"/"IBM Metrics API Key" --password) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' <(../1-click/generate-bosh-lite-in-sl-manifest.sh ${pipeline_name}-bosh-lite) )" \
  -v bosh_lite_name=${pipeline_name}-bosh-lite \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git'

fly -t flintstone expose-pipeline --pipeline ${pipeline_name}
fly -t flintstone unpause-pipeline --pipeline ${pipeline_name}

rm -f extra_args.yml
