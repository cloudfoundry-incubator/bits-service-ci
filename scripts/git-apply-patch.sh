#!/bin/bash -ex

pwd
ls git-cf-release

cd $1
git am < $2
