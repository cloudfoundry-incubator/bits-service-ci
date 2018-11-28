#!/bin/bash -e

function main {
    init
    install_bits_dependencies
    build_bits_binary
    provide_bits_layer_to_docker_parts
    provide_eirinifs_layer_to_docker_parts
}

function init {
    printf "[INFO] Init the environement for the task\n"
    export ROOT_DIR=$(pwd)
    export GOPATH="${ROOT_DIR}/bits-service-release"
    export PATH=$PATH:$GOPATH/bin
}

function install_bits_dependencies {
    printf "[INFO] Install the dependencies for the bits-service ...\n"
    pushd bits-service-release/src/github.com/cloudfoundry-incubator/bits-service
        glide install
    popd
}

function build_bits_binary {
    printf "[INFO] Compile the bits-service ...\n"
    printf "[INFO] The GOPATH is set to: ${GOPATH} \n"
    pushd bits-service-release/docker
        GOOS=linux GOARCH=amd64 go build -o bitsgo github.com/cloudfoundry-incubator/bits-service/cmd/bitsgo
    popd
}

function provide_bits_layer_to_docker_parts {
    printf "[INFO] Copy bits layer to the output folder.\n"
    cp -av bits-service-release/docker/ docker-parts/
}

function provide_eirinifs_layer_to_docker_parts {
    mkdir -p ${ROOT_DIR}/docker-parts/docker/assets
    printf "[INFO] Copy eirini layer to the output folder.\n"
    cp -v eirini-resources/eirinifs_v$(cat ${ROOT_DIR}/eirini-resources/version).tar ${ROOT_DIR}/docker-parts/docker/assets/eirinifs.tar
}

main
