#!/bin/bash -ex
echo "$INTEGRATION_TEST_SETUP" > /tmp/integration_test.yml

export CONFIG=/tmp/integration_test.yml

export GOPATH=$(mktemp -d)
export PATH=$GOPATH/bin:$PATH

mkdir -p $GOPATH/src/github.com/petergtz $GOPATH/bin $GOPATH/pkg
cp -a bitsgo $GOPATH/src/github.com/petergtz
cd $GOPATH/src/github.com/petergtz/bitsgo

glide install
pushd vendor/github.com/onsi/ginkgo/ginkgo
    go install
popd

cd $GOPATH/src/github.com/petergtz/bitsgo/blobstores/contract_integ_test
ginkgo -r --focus=$BLOBSTORE_TYPE
