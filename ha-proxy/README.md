# HA Proxy Configuration for Concourse

# Updating the HAProxy configuration

In order to deploy and updated HAProxy config, edit the config file `haproxy.cfg`, commit and push changes. The pipeline job [ha-proxy-config-sync](https://ci.flintstone.cf.cloud.ibm.com/teams/main/pipelines/ha-proxy-config-sync) will trigger and deploy the changed config.

# Installation of a new instance

- Stand up a new Softlayer VM with Ubuntu

- Install HAproxy:

  ```sh
  add-apt-repository ppa:vbernat/haproxy-1.6
  apt-get update
  apt-get install haproxy
  ```

- Install [certbot](https://certbot.eff.org/lets-encrypt/ubuntutrusty-haproxy)

- Register the VM's IP address in [`bits-service-private-config`](https://github.com/cloudfoundry/bits-service-private-config/blob/master/environments/softlayer/concourse/ha-proxy-host)

- Deploy the configuration files by manually triggering the pipeline job [ha-proxy-config-sync](https://ci.flintstone.cf.cloud.ibm.com/teams/main/pipelines/ha-proxy-config-sync)

- Ensure that the firewall configuration of the Softlayer account allows connections to the machine's IP address and configured ports.

# Configuration specific to Concourse

The section `backend concourse1` in `haproxy.cfg` must have the IP address of the `web` jobs of the Concourse deployment.

1. Find the IP addresses of the web workers:

    ```sh
    $ bosh -e sl -d concourse is | grep web
    web/39d38076-738a-4e26-a950-ef5ed4b61f18        running z1      10.175.143.157
    web/42f68d11-ca32-4155-9023-53cf28a2fc4d        running z1      10.175.143.152
    ```

1. Update the backend section of `haproxy.cfg`:

    ```
    backend concourse1
       # web instances
       server cc1-1 10.175.143.157:8080 check
       server cc1-2 10.175.143.152:8080 check
    ```

1. Trigger the pipeline job [ha-proxy-config-sync](https://ci.flintstone.cf.cloud.ibm.com/teams/main/pipelines/ha-proxy-config-sync) in order to deploy the changes.

# Debugging

# Check if load balancing works

Look for HAProxy alternating between `cc1-1` and `cc1-2`:

```sh
$ tail -f /var/log/haproxy.log
Jun 29 08:09:45 ngproxy1.flintstone.us-south.bluemix.net haproxy[25783]: 195.212.29.177:44654 [29/Jun/2018:08:09:40.125] www-https~ concourse1/cc1-2 4774/0/113/111/4998 200 282 - - ---- 13/13/1/1/0 0/0 "GET /api/v1/info HTTP/1.1"
Jun 29 08:09:45 ngproxy1.flintstone.us-south.bluemix.net haproxy[25783]: 195.212.29.177:44652 [29/Jun/2018:08:09:40.125] www-https~ concourse1/cc1-1 4776/0/117/116/5009 200 232 - - ---- 13/13/0/1/0 0/0 "GET /api/v1/pipelines HTTP/1.1"
```
