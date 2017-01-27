#!/bin/bash -ex

perl -pi -e 's/^[^0-9]*((\d+\.)*)(\d+)(.*pre.*)$/$1.($3+1)/e' bits-service-client/lib/bits_service_client/version.rb

cp -r bits-service-client bumped/bits-service-client
