#!/bin/bash -ex

export BOSH_USER="${BOSH_USERNAME}"
export BOSH_PASSWORD="${BOSH_PASSWORD}"
bosh target "${BOSH_TARGET}"

bosh update cloud-config manifests/"${MANIFEST}"
