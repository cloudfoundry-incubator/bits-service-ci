#!/bin/bash -e

fly -t $1 login -c https://ci.flintstone.cf.cloud.ibm.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)