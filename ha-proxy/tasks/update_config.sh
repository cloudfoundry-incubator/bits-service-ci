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

STAUTS_OK=$(curl -s http://flintstone.ci.cf-app.com/ -L -I | grep 200 | wc -l)

if [ ${STAUTS_OK} -eq 1 ]
then
    printf "Update woz successful\n"
    exit 0
else
    printf "Update wozn't successful\n"
    printf "Verify with: 'curl -s http://flintstone.ci.cf-app.com/ -L -I | grep 200 | wc -l'\n"
    exit 1
fi
