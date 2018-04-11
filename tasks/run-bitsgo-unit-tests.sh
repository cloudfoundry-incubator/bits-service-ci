#!/bin/bash -ex

export GOPATH=$(mktemp -d)
export PATH=$GOPATH/bin:$PATH

mkdir -p $GOPATH/src/github.com/petergtz $GOPATH/bin $GOPATH/pkg
cp -a bitsgo $GOPATH/src/github.com/petergtz
cd $GOPATH/src/github.com/petergtz/bitsgo

glide install
pushd vendor/github.com/onsi/ginkgo/ginkgo
    go install
popd

ginkgo -r --skipPackage=blobstores/contract_integ_test
