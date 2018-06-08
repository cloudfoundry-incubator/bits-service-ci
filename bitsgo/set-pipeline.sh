#!/bin/bash -e

cd $(dirname $0)
../fly-login.sh flintstone

if [ -z $1 ]; then
  cat << EOF
    Missing parameter indicating blobstore type
    usage: ./set-pipeline.sh up <blobstore type>

    blobstore types:
    - aws-s3
    - cos-s3
    - webdav
    - google-service-account
    - google-s3
    - azure
EOF
  exit 1
fi

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
  export cos_host=s3.eu-geo.objectstorage.softlayer.net
  export resource_directory_key=cf-bits
  export buildpack_directory_key=cf-bits
  export droplet_directory_key=cf-bits
  export app_package_directory_key=cf-bits
elif [ "$1" == "openstack" ]; then
  export openstack_username=$(lpass show "Shared-Flintstone"/"Bluemix Swift" --username)
  export openstack_api_key=$(lpass show "Shared-Flintstone"/"Bluemix Swift" --password)
  export openstack_temp_url_key=$(lpass show "Shared-Flintstone"/"Bluemix Swift Temp-Url-Key" --password)
  export openstack_domain_id=$(lpass show "Shared-Flintstone"/"Bluemix Swift Temp-Url-Key" --username)
  export resource_directory_key=cf-bits
  export buildpack_directory_key=cf-bits
  export droplet_directory_key=cf-bits
  export app_package_directory_key=cf-bits
elif [ "$1" == "azure" ]; then
  export azure_storage_account_name=$(lpass show "Shared-Bluemix"/Azure --username)
  export azure_storage_access_key=$(lpass show "Shared-Bluemix"/Azure --password)
  export environment=AzureCloud
  export resource_directory_key=cf-bits
  export buildpack_directory_key=cf-bits
  export droplet_directory_key=cf-bits
  export app_package_directory_key=cf-bits
elif [ "$1" == "google-service-account" ]; then
  export gcs_project=petergtz
  export gcs_service_account_email=$(lpass show "Shared-Flintstone"/GCP-Service-Account-Client --username)
  export resource_directory_key=pego-blobstore
  export buildpack_directory_key=pego-blobstore
  export droplet_directory_key=pego-blobstore
  export app_package_directory_key=pego-blobstore
elif [ "$1" == "google-s3" ]; then
  export google_storage_access_key_id=$(lpass show "Shared-Flintstone"/GCP-S3-API-Key --username)
  export google_storage_secret_access_key=$(lpass show "Shared-Flintstone"/GCP-S3-API-Key --password)
  export resource_directory_key=pego-test
  export buildpack_directory_key=pego-test
  export droplet_directory_key=pego-test
  export app_package_directory_key=pego-test
fi

eval "echo \"$(cat $1.yml)\"" > extra_args.yml

# Hack: using sed to work around Concourse limitation. See bosh-create-env.sh for more details.
fly \
  -t flintstone \
  set-pipeline \
  -p ${pipeline_name} \
  -c <(spruce --concourse merge ~/workspace/1-click-bosh-lite-pipeline/template.yml ../1-click/recreate-bosh-lite-every-morning.yml deploy-and-test-cf.yml extra_args.yml) \
  -l <(lpass show "Shared-Flintstone"/ci-config --notes) \
  -v bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username) \
  -v bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password) \
  -v ibm_metrics_api_key=$(lpass show "Shared-Flintstone"/"IBM Metrics API Key" --password) \
  -v github-private-key="$(lpass show "Shared-Flintstone"/Github --notes --sync=no)" \
  -v bosh-manifest="$(sed -e 's/((/_(_(/g' <(../1-click/generate-bosh-lite-in-sl-manifest.sh ${pipeline_name}-bosh-lite) )" \
  -v bosh_lite_name=${pipeline_name}-bosh-lite \
  -v state_git_repo='git@github.com:cloudfoundry/bits-service-private-config.git' \
  -v sl_vm_domain=flintstone.ams

fly -t flintstone expose-pipeline --pipeline ${pipeline_name}

rm -f extra_args.yml
