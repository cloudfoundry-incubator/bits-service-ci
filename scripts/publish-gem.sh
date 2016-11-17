#!/bin/bash -ex

mkdir -p ~/.ssh
private_key_path=~/.ssh/id_rsa
ruby -e "File.write(File.expand_path(ENV['private_key_path']), ENV['GIT_PRIVATE_KEY'])"
chmod 0600 $private_key_path

eval $(ssh-agent) >/dev/null 2>&1
trap "kill $SSH_AGENT_PID" 0
ssh-add $private_key_path >/dev/null

cat > ~/.ssh/config <<EOF
StrictHostKeyChecking no
LogLevel quiet
EOF
chmod 0600 ~/.ssh/config

git config --global user.name "Pipeline"
git config --global user.email flintstone@cloudfoundry.org

gem_credentials_path=~/.gem/credentials
ruby -e "File.write(File.expand_path(ENV['gem_credentials_path']), ENV['RUBYGEMS_API_KEY'])"
chmod 0600 $gem_credentials_path

cd git-bits-service-client
bundle install
bundle exec rake release
