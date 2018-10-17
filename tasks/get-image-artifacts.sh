#!/bin/bash -e
ROOT_DIR=$(pwd)
apk add sudo
# sudo ./usr/local/bin/dockerd &

ls -al /usr/local/bin
/usr/local/bin/dockerd-entrypoint.sh &

# git clone https://github.com/cloudfoundry-incubator/eirini-release.git
pushd eirini-release
    # git submodule update --init --recursive
    GOPATH=$(pwd)
    PATH=$PATH:$GPATH/bin
    echo "GOPATH is set to: ${GOPATH}"
    go get github.com/cloudfoundry-incubator/eirini

    #inswhichtall dependencies
    go get code.cloudfoundry.org/buildpackapplifecycle/env
    go get code.cloudfoundry.org/goshims/osshim
    go get gopkg.in/yaml.v2
    #todo: use glide or sth alike?


    cp eirinifs.tar ${ROOT_DIR}/bits-service-release/docker-release/assets/
popd

GOPATH="${ROOT_DIR}/bits-service-release"
echo "GOPATH is set to: ${GOPATH}"

pushd bits-service-release/docker-release
    GOOS=linux GOARCH=amd64 go build -o bitsgo github.com/cloudfoundry-incubator/bits-service/cmd/bitsgo
popd
