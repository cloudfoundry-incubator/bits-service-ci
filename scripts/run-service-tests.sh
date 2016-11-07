#!/bin/bash -ex

cd $(dirname $0)/../../bits-service

bundle install && bundle exec rake spec:all
