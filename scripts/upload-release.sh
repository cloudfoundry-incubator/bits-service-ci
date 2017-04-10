#!/bin/bash -e

bosh -u x -p x target $BOSH_TARGET
bosh login $BOSH_USERNAME $BOSH_PASSWORD

bosh upload release $RELEASE_FILE --skip-if-exists
