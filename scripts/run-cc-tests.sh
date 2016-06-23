#!/bin/bash

service mysql start

set -e

cd $(dirname $0)/../../git-cloud-controller

bundle install
bundle exec rake db:create > /dev/null
bundle exec rake db:migrate > /dev/null
bundle exec rake
