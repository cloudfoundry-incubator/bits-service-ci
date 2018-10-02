#!/bin/bash -xe

KUBECONFIG=${KUBECONFIG:?"Please make sure that KUBECONFIG is set"}

cd ~/workspace/eirini-release/scf

helm install hnative/uaa \
    --namespace uaa \
    --values ~/workspace/bits-service-private-config/kube-clusters/bits-marry-eirini/scf-config-values.yaml \
    --name uaa
