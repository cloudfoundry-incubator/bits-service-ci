#!/bin/bash -ex

. ci-tasks/scripts/bosh-login.sh

shopt -s nullglob

for stemcell in stemcells/${STEMCELL_FILES}; do
    bosh2 upload-stemcell $stemcell
done

for release in releases/${RELEASE_FILES}; do
    bosh2 upload-release $release
done

bosh2 -n -d ${DEPLOYMENT_NAME} deploy manifests/${MANIFEST_FILE}
