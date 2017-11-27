#!/bin/bash -e

if [ -n "$DEBUG" ]; then
  set -x
  export
  go version
fi

function setup_ssh() {
  echo "$SSH_KEY" >$PWD/.ssh-key
  chmod 600 $PWD/.ssh-key
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  local ip=$(echo $SSH_CONNECTION_STRING | cut -d "@" -f2)
  ssh-keyscan -t rsa,dsa $ip >>~/.ssh/known_hosts
}

function is_tunnel_up() {
  ssh $conn_str "nc -z localhost $1"
}

function wait_for_tunnel() {
  local result=1
  local n=0
  until [ $n -ge 5 ]; do
    if is_tunnel_up $1; then
      result=0
      break
    fi

    n=$(($n + 1))
    sleep 1
  done

  return $result
}

setup_ssh
conn_str="$SSH_CONNECTION_STRING -i $PWD/.ssh-key"
ssh $conn_str "ssh root@192.168.50.4 -L 80:10.244.0.34:80 -N" &
ssh $conn_str "ssh root@192.168.50.4 -L 443:10.244.0.34:443 -N" &
wait_for_tunnel 80
wait_for_tunnel 443

export GOPATH=$PWD/bits-service-release
export PATH=${GOPATH}/bin:${PATH}

cf_admin_password=$(bosh2 int $DEPLOYMENT_VARS_FILE --path /cf_admin_password)

cd bits-service-release/src/github.com/cloudfoundry-incubator/bits-service-migration-tests

cat >config.json <<EOF
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
