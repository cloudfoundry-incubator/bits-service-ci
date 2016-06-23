# Concourse

TODO: document when we do the 1.0 update

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
  $ wget https://raw.githubusercontent.com/cloudfoundry-incubator/bits-service/master/ci/concourse/haproxy.cfg --output-document=/etc/haproxy/haproxy.cfg
  $ service haproxy restart
  ```

- Verify that haproxy listens to the configured ports:

  ```
  netstat -nap | grep haproxy
  tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      8314/haproxy
  tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      8314/haproxy
  ```

- Ensure that the firewall configuration of the Softlayer Account allows connections to the given IP address and configured ports.
