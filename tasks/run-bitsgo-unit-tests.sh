#!/bin/bash -ex

export GOPATH=$(readlink -f go)
export PATH=$GOPATH/bin:$PATH

mkdir -p $GOPATH/src/github.com/cloudfoundry-incubator $GOPATH/bin $GOPATH/pkg
cp -a bits-service $GOPATH/src/github.com/cloudfoundry-incubator
cd $GOPATH/src/github.com/cloudfoundry-incubator/bits-service

glide install
pushd vendor/github.com/onsi/ginkgo/ginkgo
    go install
popd

ginkgo -r --skipPackage=blobstores/contract_integ_test
