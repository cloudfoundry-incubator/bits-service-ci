#!/bin/bash

function main {
  setup_ssh
  delete_vagrant_vm
  create_vagrant_vm
  setup_boshlite
  set_networking
}

function setup_ssh {
  echo "$SSH_KEY" > $PWD/.ssh-key
  chmod 600 $PWD/.ssh-key
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  local ip=$(echo $SSH_CONNECTION_STRING | cut -d "@" -f2)

  ssh-keyscan -t rsa,dsa $ip >> ~/.ssh/known_hosts
  export SSH_CONNECTION_STRING="$SSH_CONNECTION_STRING -i $PWD/.ssh-key"
}

function delete_vagrant_vm {
  echo "-- Deleting stale bosh-lite"
  ssh $SSH_CONNECTION_STRING "cd ~/workspace/bosh-lite && vagrant destroy --force"
}

function create_vagrant_vm {
  echo "-- Creating new bosh-lite"
  ssh $SSH_CONNECTION_STRING "cd ~/workspace/bosh-lite && vagrant up"
}

function setup_boshlite {
  echo "-- Logging in to the new director"
  ssh $SSH_CONNECTION_STRING "bosh --user admin --password admin target https://$BOSH_DIRECTOR_IP:25555 && bosh login admin admin"
  echo "-- Changing default user"
  ssh $SSH_CONNECTION_STRING "bosh create user $BOSH_USERNAME $BOSH_PASSWORD"
}

function set_networking {
  echo "-- Setting up networking"
  ssh $SSH_CONNECTION_STRING "echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward"
  ssh $SSH_CONNECTION_STRING "ip route add 10.250.0.0/16 via $BOSH_DIRECTOR_IP"
  ssh $SSH_CONNECTION_STRING "cd ~/workspace/bosh-lite && vagrant ssh -- 'sudo ip route add 10.155.248.0/24 via $VAGRANT_GATEWAY dev eth1'"
}

main
