#!/bin/bash -e

export KEY_FILE=../../../private-config/environments/softlayer/concourse/ha-maintenance.key
chmod 600 ${KEY_FILE}
printf "Downloading HAProxy config... \n"
ssh -oStrictHostKeyChecking=no -i ${KEY_FILE} ha-maintenance@${HAPROXY_IP} 'wget https://raw.githubusercontent.com/cloudfoundry-incubator/bits-service-ci/master/docs/haproxy.cfg --output-document=/etc/haproxy/haproxy.cfg'
printf "Restarting HA proxy with latest config \n"
ssh -oStrictHostKeyChecking=no -i ${KEY_FILE} ha-maintenance@${HAPROXY_IP} 'service haproxy restart'

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
