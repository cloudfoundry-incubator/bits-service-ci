#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
KEY_FILE=private-config/environments/softlayer/concourse/ha-proxy-access-key
HAPROXY_IP="$(cat private-config/environments/softlayer/concourse/ha-proxy-host)"

main() {
	chmod 600 "$KEY_FILE"
	copy-to-host etc/haproxy.cfg /etc/haproxy/
	copy-to-host opt/copy-haproxy-certs /opt/flintstone/
	copy-to-host etc/cron.d/certbot /etc/cron.d/
	restart-haproxy
	check-url https://ci.flintstone.cf.cloud.ibm.com
}

copy-to-host() {
	local -r source=${1:?Source file missing}
	local -r target=${2:?Target file missing}

	scp -o StrictHostKeyChecking=no \
		-i "$KEY_FILE" \
		-p \
		"haproxy-config/ha-proxy/files/$source" \
		"root@${HAPROXY_IP}:$target"
}

restart-haproxy() {
	ssh \
	  -o StrictHostKeyChecking=no \
		-i "$KEY_FILE" \
		"root@$HAPROXY_IP" \
		service haproxy restart
}

check-url() {
	local -r url=${1:?URL missing}
	if [ 200 -ne "$(curl -s -o /dev/null -I -w "%{http_code}" "$url")" ]; then
		echo "$url responded with status that is not 200."
		exit 1
	fi
}

main
