#!/bin/bash -ex
echo "$INTEGRATION_TEST_SETUP" > /tmp/integration_test.yml

export CONFIG=/tmp/integration_test.yml

export GOPATH=$(mktemp -d)
export PATH=$GOPATH/bin:$PATH

#update GO Version
sudo rm -rf /usr/local/go
sudo apt-get install gzip -y
wget https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.10.1.linux-amd64.tar.gz
echo $PATH | grep "/usr/local/go/bin"

mkdir -p $GOPATH/src/github.com/petergtz $GOPATH/bin $GOPATH/pkg
cp -a bitsgo $GOPATH/src/github.com/petergtz
cd $GOPATH/src/github.com/petergtz/bitsgo

glide install
pushd vendor/github.com/onsi/ginkgo/ginkgo
    go install
popd

cd $GOPATH/src/github.com/petergtz/bitsgo/blobstores/contract_integ_test
ginkgo -r --focus=$BLOBSTORE_TYPE
