#!/bin/bash -ex

cd bits-service-release

export GOPATH=$PWD
export PATH=$GOPATH/bin:$PATH

pushd src/github.com/cloudfoundry-incubator/bits-service
    glide install
popd

bundle install

if [ "$BLOBSTORE_TYPE" == "s3" ]; then
    mkdir .private
    cat > .private/s3.sh <<EOF
export BUCKET=${BITS_DIRECTORY_KEY}
export ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export REGION=${BITS_AWS_REGION}
EOF
fi

scripts/run-system-tests.sh $BLOBSTORE_TYPE
