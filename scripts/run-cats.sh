#!/bin/bash -l

set -e -x

mkdir -p gopath/src/github.com/cloudfoundry
cp -r acceptance-tests gopath/src/github.com/cloudfoundry/cf-acceptance-tests

cf_admin_password=$( \
  bosh2 int deployment-vars/environments/${ENVIRONMENT_NAME}/deployment-vars.yml \
  --path /cf_admin_password
)
cat > config.json <<EOF
{
  "api": "api.${CF_DOMAIN}",
  "apps_domain": "${CF_DOMAIN}",
  "admin_user": "admin",
  "admin_password": "${cf_admin_password}",
  "skip_ssl_validation": true,
  "use_http": true,
  "default_timeout": 75,
  "include_apps": true,
  "include_backend_compatibility": false,
  "include_container_networking": false,
  "include_detect": true,
  "include_docker": false,
  "include_internet_dependent": true,
  "include_isolation_segments": false,
  "include_persistent_app": false,
  "include_private_docker_registry": false,
  "include_privileged_container_support": false,
  "include_route_services": false,
  "include_routing": true,
  "include_routing_isolation_segments": false,
  "include_security_groups": true,
  "include_services": true,
  "include_ssh": false,
  "include_sso": true,
  "include_tasks": true,
  "include_v3": false,
  "include_zipkin": false,
  "backend": "diego",
  "include_diego_ssh": false,
  "skip_diego_unsupported_tests": true
}
EOF
export CONFIG="$(readlink -nf config.json)"

export CF_DIAL_TIMEOUT
export CF_COLOR=false

# export CF_PLUGIN_HOME=$(mktemp -d)
# cf install-plugin /var/vcap/packages/cli-network-policy-plugin/plugin/network-policy-plugin-linux64 -f

cd gopath/src/github.com/cloudfoundry/cf-acceptance-tests

echo '################################################################################################################'
echo $(go version)
echo CONFIG=$CONFIG
env | sort
echo '################################################################################################################'

bin/test -r -slowSpecThreshold=120 -randomizeAllSpecs \
  -nodes="${NODES}" -skipPackage=helpers -keepGoing
