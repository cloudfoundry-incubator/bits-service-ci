#!/bin/bash -ex

cd $(dirname $0)/../../git-bits-service-client

bundle install && bundle exec rspec spec
