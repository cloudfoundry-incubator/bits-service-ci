#!/bin/bash -ex

cd $1
git am < $2
