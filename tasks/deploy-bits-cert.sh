#!/bin/bash -xe


set -eo pipefail
IFS=$'\n\t'

source ci-resources/scripts/ibmcloud-functions
ibmcloud-login
export-kubeconfig "$CLUSTER_NAME"

export IP=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}')
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
while [ "$(kubectl get secrets -n scf | grep bits-cert)" != "" ]; do
    sleep 1;
done
set -e

kubectl create secret generic bits-cert -n scf --from-file=/tmp/certs/cert_file --from-file=/tmp/certs/key_file

while [ "$(kubectl get secrets -n scf | grep bits-cert)" == "" ]; do
    sleep 1;
done

set +e
kubectl delete job bits-cert-copy -n scf
set -e

while [ "$(kubectl get jobs -n scf | grep bits-cert-copy)" != "" ]; do
    sleep 1;
done

cat > /tmp/bits-cert-copy.yml << EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: bits-cert-copy
spec:
  template:
    spec:
      serviceAccountName: "opi"
      restartPolicy: OnFailure
      volumes:
      - name: host-docker
        hostPath:
          path: /etc/docker
          type: Directory
      containers:
      - name: copy-certs
        env:
        - name: BITS_REGISTRY
          value: registry.$IP.nip.io:6666
        image: pego/bits-cert-copy:latest
        volumeMounts:
        - name: host-docker
          mountPath: /workspace/docker
EOF

kubectl apply -f /tmp/bits-cert-copy.yml -n scf
while [ "$(kubectl get jobs -n scf | grep bits-cert-copy)" == "" ]; do
    sleep 1;
done

kubectl delete pod $(kubectl get pod -n scf | grep eirini | cut -f1 -d' ') -n scf
kubectl delete pod $(kubectl get pod -n scf | grep bits | cut -f1 -d' ') -n scf

