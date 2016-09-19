#!/bin/bash -ex

service mysql start

cd $(dirname $0)/../../git-cloud-controller

bundle install
bundle exec rake
