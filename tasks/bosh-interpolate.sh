#!/bin/bash -ex

if [[ "${ENVIRONMENT_NAME}" == 'aws' ]] ||
   [[ "${ENVIRONMENT_NAME}" == 'blobstore-local' ]] ||
   [[ "${ENVIRONMENT_NAME}" == 'softlayer' ]]; then
  deployment_vars=$(readlink -f deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-cf.yml)
else
  deployment_vars="deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}-bosh-lite/cf-deployment/vars.yml"
fi

if [ "$CF_DOMAIN" == "" ]; then
  CF_DOMAIN=$(cat deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}-bosh-lite/hosts | cut -d ' ' -f1 ).nip.io
fi

# TODO: (ae, pego) Get rid of '-o'??

if [[ "${BLOBSTORE_TYPE}" != 'webdav' ]] &&
   [[ "${BLOBSTORE_TYPE}" != 's3' ]] &&
   [[ "${BLOBSTORE_TYPE}" != 'gcs-service-account' ]] &&
   [[ "${BLOBSTORE_TYPE}" != 'local' ]]; then
  echo "Unknown blobstore type: ${BLOBSTORE_TYPE}"
  exit 1
fi

case "${IAAS}" in
'bosh-lite')
  iaas='-o cf-deployment/operations/bosh-lite.yml'
  ;;
'aws')
  iaas='-o cf-deployment/operations/aws.yml'
  ;;
'softlayer')
  # TODO: change stemcell name?
  ;;
*)
  echo "Unknown IAAS: ${IAAS}"
  exit 1
  ;;
esac

if [[ "${BLOBSTORE_TYPE}" != 'webdav' ]]; then
  CONFIGURE_BITS="-o cf-deployment/operations/bits-service/configure-bits-service-${BLOBSTORE_TYPE}.yml"
fi

bosh2 interpolate cf-deployment/cf-deployment.yml \
  --vars-store "${deployment_vars}" \
  ${iaas} \
  -v system_domain="${CF_DOMAIN}" \
  -o ci-tasks/operations/stemcell-version.yml \
  -v stemcell_version="latest" \
  -o ci-tasks/operations/global-env-property.yml \
  -v global_env=${IAAS} \
  -o cf-deployment/operations/bits-service/use-bits-service.yml \
  $CONFIGURE_BITS \
  ${OPERATIONS} \
  ${VARIABLES} \
  > manifests/manifest.yml

cp manifests/manifest.yml $(dirname $deployment_vars)
echo ${CF_DOMAIN} > $(dirname $deployment_vars)/system_domain

export PATH=$PATH:$(readlink -f ci-tasks/tasks)
pushd deployment-vars
    git add .
    commit-if-changed.sh "Update ${ENVIRONMENT_NAME} deployment vars"
popd

cp -r deployment-vars updated/deployment-vars
