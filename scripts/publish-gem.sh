#!/bin/bash -ex

mkdir -p ~/.ssh

private_key_path=~/.ssh/id_rsa
echo "$GIT_PRIVATE_KEY" > $private_key_path
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

gem_credentials_path=~/.gem/credentials
echo "$RUBYGEMS_API_KEY" > $gem_credentials_path
chmod 0600 $gem_credentials_path

cd git-bits-service-client
bundle config --global silence_root_warning 1
bundle install

git checkout -b ci-tag-version
git push -u origin HEAD

bundle exec rake release

git push origin --delete ci-tag-version
