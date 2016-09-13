#!/bin/bash -ex

cd $(dirname $0)/../../git-bits-service-client

# work around flaky DNS resolution
for i in $(seq 1 254); do
  echo 10.250.0.$i 10.250.0.$i.xip.io >> /etc/hosts
done

bundle install && bundle exec rspec spec
