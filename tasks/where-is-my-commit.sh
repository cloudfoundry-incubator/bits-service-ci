#!/bin/bash -e

cd $(dirname $0)

bonus-miles -t flintstone -r bits-service-release -p bits-service -a < bits-service-release-jobs
