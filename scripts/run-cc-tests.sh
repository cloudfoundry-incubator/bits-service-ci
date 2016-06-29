#!/bin/bash

service mysql start

set -e

cd $(dirname $0)/../../git-cloud-controller

bundle install
bundle exec rake
