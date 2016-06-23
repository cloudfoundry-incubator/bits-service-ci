#!/bin/bash -ex

cd $(dirname $0)/../../

bundle install && bundle exec rake spec:all
