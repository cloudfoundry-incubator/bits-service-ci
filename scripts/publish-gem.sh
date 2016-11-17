#!/bin/bash -ex

mkdir -p ~/.ssh
private_key_path=~/.ssh/id_rsa
echo $GIT_PRIVATE_KEY > $private_key_path
chmod 0600 $private_key_path

eval $(ssh-agent) >/dev/null 2>&1
trap "kill $SSH_AGENT_PID" 0
SSH_ASKPASS=false DISPLAY= ssh-add $private_key_path >/dev/null

cat > ~/.ssh/config <<EOF
StrictHostKeyChecking no
LogLevel quiet
EOF
chmod 0600 ~/.ssh/config

git config --global user.name "Pipeline"
git config --global user.email flintstone@cloudfoundry.org

echo $RUBYGEMS_API_KEY > ~/.gem/credentials

cd git-bits-service-client
bundle install
bundle exec rake release
