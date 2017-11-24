#!/bin/bash -e

if [ -n "$DEBUG" ]; then
    set -x
    export
    go version
fi


# function setup_ssh {
#   echo "$SSH_KEY" > $PWD/.ssh-key
#   chmod 600 $PWD/.ssh-key
#   mkdir -p ~/.ssh && chmod 700 ~/.ssh
#   local ip=$(echo $SSH_CONNECTION_STRING | cut -d "@" -f2)

#   ssh-keyscan -t rsa,dsa $ip >> ~/.ssh/known_hosts
#   export SSH_CONNECTION_STRING="$SSH_CONNECTION_STRING -i $PWD/.ssh-key"
# }

# setup_ssh
# ssh $SSH_CONNECTION_STRING "ssh root@192.168.50.4 -L 80:10.244.0.34:80 -N" &
# ssh $SSH_CONNECTION_STRING "ssh root@192.168.50.4 -L 443:10.244.0.34:443 -N" &
# sleep 3

export GOPATH=$PWD/bits-service-release
export PATH=${GOPATH}/bin:${PATH}

cd bits-service-release/src/github.com/cloudfoundry-incubator/bits-service-migration-tests

cat > config.json <<EOF
{
  "api": "api.${CF_DOMAIN}",
  "apps_domain": "${CF_DOMAIN}",
  "admin_user": "admin",
  "admin_password": "${cf_admin_password}",
  "skip_ssl_validation": true,
  "use_http": true,
  "backend": "diego",
  "default_timeout": 75,
  "cf_push_timeout": 240,
  "persistent_app_org": "${BSMT_PERSISTENT_ORG}",
  "persistent_app_space": "${BSMT_PERSISTENT_SPACE}"
}
EOF
export CONFIG="$(readlink -nf config.json)"

bin/test -r $noColorFlag -slowSpecThreshold=120 -randomizeAllSpecs $verbose -v -progress -keepGoing $test_suite
