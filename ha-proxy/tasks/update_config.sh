#!/bin/bash -e

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export KEY_FILE=${BASEDIR}/../../../private-config/environments/softlayer/concourse/ha-proxy-access-key
export HOSTFILE=${BASEDIR}/../../../private-config/environments/softlayer/concourse/ha-proxy-host
export USERFILE=${BASEDIR}/../../../private-config/environments/softlayer/concourse/ha-proxy-maintenance-user

HAPROXY_IP="$(cat ${HOSTFILE})"
USER="$(cat ${USERFILE})"
export HAPROXY_IP USER

# prepare for ssh connection
chmod 600 ${KEY_FILE}

printf "Downloading HAProxy config... \n"
ssh -oStrictHostKeyChecking=no -i ${KEY_FILE} root@${HAPROXY_IP} 'wget https://raw.githubusercontent.com/cloudfoundry-incubator/bits-service-ci/master/docs/haproxy.cfg --output-document=/etc/haproxy/haproxy.cfg'
printf "Restarting HA proxy with latest config \n"
ssh -oStrictHostKeyChecking=no -i ${KEY_FILE} root@${HAPROXY_IP} 'service haproxy restart'

declare -r CI_URL="https://ci.flintstone.cf.cloud.ibm.com"

if [ 200 = "$(curl -s -o /dev/null -I -w "%{http_code}" $CI_URL)" ];
then
    printf "Update woz successful\n"
    exit 0
else
    printf "Update wozn't successful\n"
    printf "Verify with: 'curl -L $CI_URL'\n"
    exit 1
fi
