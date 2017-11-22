#!/bin/bash -e

if [ -n "$DEBUG" ]; then
    set -x
    export
    go version
fi


function setup_ssh {
  echo "$SSH_KEY" > $PWD/.ssh-key
  chmod 600 $PWD/.ssh-key
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  local ip=$(echo $SSH_CONNECTION_STRING | cut -d "@" -f2)

  ssh-keyscan -t rsa,dsa $ip >> ~/.ssh/known_hosts
  ssh $SSH_CONNECTION_STRING -i $PWD/.ssh-key -L 80:$REMOTE_HOST:8080 -N &
  ssh $SSH_CONNECTION_STRING -i $PWD/.ssh-key -L 443:$REMOTE_HOST:4443 -N &
  sleep 3 # just making sure that the tunnels are up
  export SSH_CONNECTION_STRING="$SSH_CONNECTION_STRING -i $PWD/.ssh-key"
}

setup_ssh
# TODO: instead change the system domain in the cf deployment and use change-ip
echo "127.0.0.1 api.bosh-lite.com" >> /etc/hosts
echo "127.0.0.1 uaa.bosh-lite.com" >> /etc/hosts
echo "127.0.0.1 login.bosh-lite.com" >> /etc/hosts
echo "127.0.0.1 ssh.bosh-lite.com" >> /etc/hosts
echo "127.0.0.1 doppler.bosh-lite.com" >> /etc/hosts

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

bin/test -r $noColorFlag -slowSpecThreshold=120 -randomizeAllSpecs $verbose -keepGoing $test_suite
