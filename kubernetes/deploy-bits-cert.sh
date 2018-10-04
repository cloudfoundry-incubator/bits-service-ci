#!/bin/bash -xe

KUBECONFIG=${KUBECONFIG:?"Please make sure that KUBECONFIG is set"}

export IP=$(cat ~/workspace/bits-service-private-config/kube-clusters/bits-marry-eirini/ip)
export REGISTRY=registry.$IP.nip.io

cat > /tmp/ssl.conf << EOF
[ req ]
distinguished_name     = req_distinguished_name
prompt                 = no

[ req_distinguished_name ]
O                      = Local Secure Registry for Kubernetes
CN                     = $REGISTRY
emailAddress           = eirini@cloudfoundry.org
EOF

mkdir -p /tmp/certs
openssl req -config /tmp/ssl.conf \
        -newkey rsa:4096 \
        -nodes \
        -sha256 \
        -x509 \
        -days 265 \
        -keyout /tmp/certs/key_file \
        -out /tmp/certs/cert_file

set +e
kubectl delete secret bits-cert -n scf
set -e
kubectl create secret generic bits-cert -n scf --from-file=/tmp/certs/cert_file --from-file=/tmp/certs/key_file

set +e
kubectl delete job bits-cert-copy -n scf
set -e

kubectl apply -f <(sed -e "s/IP/$IP/g" bits-cert-copy.yml) -n scf

kubectl delete pod $(kubectl get pod -n scf | grep eirini | cut -f1 -d' ') -n scf
kubectl delete pod $(kubectl get pod -n scf | grep bits | cut -f1 -d' ') -n scf

