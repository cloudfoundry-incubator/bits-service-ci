#!/bin/bash -ex

if [[ "${ENVIRONMENT_NAME}" == 'aws' ]] ||
   [[ "${ENVIRONMENT_NAME}" == 'blobstore-local' ]] ||
   [[ "${ENVIRONMENT_NAME}" == 'softlayer' ]]; then
  deployment_vars=$(readlink -f deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars-${DEPLOYMENT_NAME}.yml)
else
  deployment_vars="deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}-bosh-lite/cf-deployment/vars.yml"
fi

if [ "$CF_DOMAIN" == "" ]; then
  CF_DOMAIN=$(cat deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}-bosh-lite/hosts | cut -d ' ' -f1 ).nip.io
fi

# TODO: (ae, pego) Get rid of '-o'??

if [[ "${BLOBSTORE_TYPE}" != 'webdav' ]] &&
   [[ "${BLOBSTORE_TYPE}" != 's3' ]] &&
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

bosh2 interpolate cf-deployment/cf-deployment.yml \
  --vars-store "${deployment_vars}" \
  -o cf-deployment/operations/rename-deployment.yml \
  -v deployment_name="${DEPLOYMENT_NAME}" \
  ${iaas} \
  -v system_domain="${CF_DOMAIN}" \
  -o ci-tasks/operations/stemcell-version.yml \
  -v stemcell_version="latest" \
  -o ci-tasks/operations/global-env-property.yml \
  -v global_env=${IAAS} \
  -o cf-deployment/operations/experimental/bits-service.yml \
  -o cf-deployment/operations/experimental/enable-bits-service-consul.yml \
  -o cf-deployment/operations/experimental/bits-service-"${BLOBSTORE_TYPE}".yml \
  -o ci-tasks/operations/remove-statsd-injector.yml \
  ${OPERATIONS} \
  ${VARIABLES} \
  > manifests/manifest.yml

echo "Content of manifests/manifest.yml:"
cat manifests/manifest.yml

# work around for bosh-lite environemnts to fix git add
if [[ "${ENVIRONMENT_NAME}" != 'aws' ]] ||
   [[ "${ENVIRONMENT_NAME}" != 'blobstore-local' ]] ||
   [[ "${ENVIRONMENT_NAME}" != 'softlayer' ]]; then
  deployment_vars=$(readlink -f "deployment-vars/environments/softlayer/director/${ENVIRONMENT_NAME}-bosh-lite/cf-deployment/vars.yml")
fi

REPO_DIR="$(readlink -f deployment-vars)" \
FILENAME="${deployment_vars}" \
COMMIT_MESSAGE="Update ${ENVIRONMENT_NAME} deployment vars" \
./ci-tasks/scripts/commit-file-if-changed.sh

cp -r deployment-vars updated/deployment-vars
