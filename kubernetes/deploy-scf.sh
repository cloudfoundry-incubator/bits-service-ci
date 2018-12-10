#!/bin/bash -xe

KUBECONFIG=${KUBECONFIG:?"Please make sure that KUBECONFIG is set"}

SECRET=$(kubectl get pods --namespace uaa -o jsonpath='{.items[*].spec.containers[?(.name=="uaa")].env[?(.name=="INTERNAL_CA_CERT")].valueFrom.secretKeyRef.name}')
CA_CERT="$(kubectl get secret $SECRET --namespace uaa -o jsonpath="{.data['internal-ca-cert']}" | base64 --decode -)"

helm upgrade --install scf ~/workspace/eirini-release/scf/helm/cf
    --namespace scf \
    --values ~/workspace/bits-service-private-config/kube-clusters/bits-marry-eirini/scf-config-values.yaml
    --set "secrets.UAA_CA_CERT=${CA_CERT}"

# TODO wait for containers
