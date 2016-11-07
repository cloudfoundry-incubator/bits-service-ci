#!/bin/bash -ex

pwd
ls

cd $1
git am < $2
