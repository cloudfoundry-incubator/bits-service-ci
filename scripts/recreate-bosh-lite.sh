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
  upload_stemcell
  upload_remote_release "https://bosh.io/d/github.com/cloudfoundry-incubator/diego-release?v=${DIEGO_RELEASE_VERSION}"
  upload_remote_release "https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release?v=${ETCD_RELEASE_VERSION}"
  upload_remote_release "https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release?v=${GARDEN_LINUX_RELEASE_VERSION}"
  upload_remote_release "https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release?v=${CFLINUXFS2_ROOTFS_RELEASE_VERSION}"
  echo "-- Changing default user"
  ssh $SSH_CONNECTION_STRING "bosh create user $BOSH_USERNAME $BOSH_PASSWORD"
}

function upload_stemcell {
  echo "-- Uploading stemcell"
  ssh $SSH_CONNECTION_STRING "wget --quiet 'https://s3.amazonaws.com/bosh-warden-stemcells/bosh-stemcell-3147-warden-boshlite-ubuntu-trusty-go_agent.tgz' --output-document=stemcell.tgz"
  ssh $SSH_CONNECTION_STRING "bosh upload stemcell stemcell.tgz"
}

function set_networking {
  echo "-- Setting up networking"
  ssh $SSH_CONNECTION_STRING "echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward"
  ssh $SSH_CONNECTION_STRING "ip route add 10.250.0.0/16 via $BOSH_DIRECTOR_IP"
  ssh $SSH_CONNECTION_STRING "cd ~/workspace/bosh-lite && vagrant ssh -- 'sudo ip route add 10.155.248.0/24 via $VAGRANT_GATEWAY dev eth1'"
}

function upload_remote_release {
  local release_url=$1
  echo "-- Uploading release: ${release_url}"

  ssh $SSH_CONNECTION_STRING "wget '$release_url' -O remote_release.tgz"
  ssh $SSH_CONNECTION_STRING "bosh upload release remote_release.tgz"
}

main
