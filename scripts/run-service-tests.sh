#!/bin/bash -ex

cd $(dirname $0)/../../git-bits-service

bundle install && bundle exec rake spec:all
