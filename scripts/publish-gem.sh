#!/bin/bash -ex

latest_rubygems_version=$(gem search bits_service_client --pre --no-verbose | sed 's/bits_service_client (\([^,]*\).*/\1/')
new_version=$(grep VERSION git-bits-service-client/lib/bits_service_client/version.rb | sed 's/.*VERSION = //' | sed "s/'//g")
if [ "$latest_rubygems_version" == "$new_version" ]; then
  echo "rubygems version ($latest_rubygems_version) is the same as the one in the git repo ($new_version). Exiting."
  exit 0
fi

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
