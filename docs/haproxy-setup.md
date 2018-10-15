# Concourse

TODO: document when we do the 1.0 update


# Updating the haproxy configuration
In order to update the ha-proxy config follow these steps

- edit the config file ```docs/haproxy.cfg``` and commit changes
- the changes will be picked up by the pipeline job [ha-proxy-config-sync](https://flintstone.ci.cf-app.com/teams/main/pipelines/ha-proxy-config-sync/jobs/update%20haproxy)  and deployed automatically
- Done.
- If in doubt, verify the changes by logging in to the machine and review the config manually


# HA Proxy

- Get certificates from Lastpass and copy it to the host:

  ```
  $ lpass show "Shared-Flintstone"/"*.ci.cf-app.com Certificate" --notes > cf-app.com.pem
  $ scp cf-app.com.pem root@10.155.248.190:/etc/ssl/private/cf-app.com.pem
  ```

- Standup a new Softlayer VM with Ubuntu

- Install HAproxy

  ```
  add-apt-repository ppa:vbernat/haproxy-1.6
  apt-get update
  apt-get install haproxy
  ```

- Get the flintstone-specific config and apply it

  ```
  $ wget https://raw.githubusercontent.com/cloudfoundry-incubator/bits-service-ci/master/docs/haproxy.cfg --output-document=/etc/haproxy/haproxy.cfg
  $ service haproxy restart
  ```

- Verify that haproxy listens to the configured ports:

  ```
  netstat -nap | grep haproxy
  tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      8314/haproxy
  tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      8314/haproxy
  ```

- Ensure that the firewall configuration of the Softlayer Account allows connections to the given IP address and configured ports.

# More Information

## Haproxy Setup for Concourse Ci

This describes how we map with ha-proxy the concourse external_url on the web instance ips.

1. get the login data from Softlayer Control Center for the machine `haproxy.flintstone.bluemix.net`

2. login into the machine via ssh

3. edit the config of the Haproxy with your favorite editor

4. open the config file
```
bash$  sudo vim /etc/haproxy/haproxy.cfg
```

and update the section `backend concourse1` with the new web jobs ip from the concours deplyoment

```
bosh -e sl -d concourse is | grep web
web/39d38076-738a-4e26-a950-ef5ed4b61f18        running z1      10.175.143.157
web/42f68d11-ca32-4155-9023-53cf28a2fc4d        running z1      10.175.143.152
```
/etc/haproxy/haproxy.cfg
```
...
backend concourse1
   #web instances
   server cc1-1 10.175.143.157:8080 check
   server cc1-2 10.175.143.152:8080 check
...
```
5. restart to laod the config
```
bash$  service haproxy restart
```

## HA Proxy Logging
check if loadbalacing works
```
bash$ tail -f /var/log/haproxy.log
...
course1/cc1-2 4889/0/0/111/5000 401 211 - - ---- 13/13/2/2/0 0/0 "GET /auth/userinfo HTTP/1.1"
Jun 29 08:09:45 ngproxy1.flintstone.us-south.bluemix.net haproxy[25783]: 195.212.29.177:44654 [29/Jun/2018:08:09:40.125] www-https~ concourse1/cc1-2 4774/0/113/111/4998 200 282 - - ---- 13/13/1/1/0 0/0 "GET /api/v1/info HTTP/1.1"
Jun 29 08:09:45 ngproxy1.flintstone.us-south.bluemix.net haproxy[25783]: 195.212.29.177:44652 [29/Jun/2018:08:09:40.125] www-https~ concourse1/cc1-1 4776/0/117/116/5009 200 232 - - ---- 13/13/0/1/0 0/0 "GET /api/v1/pipelines HTTP/1.1"
...
```
