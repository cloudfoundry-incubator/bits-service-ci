#!/bin/bash

bosh -u x -p x target $BOSH_TARGET
bosh login $BOSH_USERNAME $BOSH_PASSWORD
bosh cleanup --all

