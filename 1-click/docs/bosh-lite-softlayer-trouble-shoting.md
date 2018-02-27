# Bosh-lite on Soft-Layer

Purpose is of this, is to have bosh-lite (container based cf) on
Softlayer datacenter instead of a local machine and virtualbox.

Current status is that we a running a cf-deployment on SL, where everything works from outside of the VM.

### architecture diagram

```
                                                        SoftLayer VM
                                              +---------------------------------------+
                                              |                                       |
                                              |     +-----------------------------+   |
                                              |     |  Cloud Controller           |   |
                                              |  +> |  garden container           |   |
                    Container  to Container   |  |  +-----------------------------+   |
                    Network does not support  |  |                                    |
                    internal http and https   |  | <- 10.244.0.0 /20                  |
                    connection                |  |                                    |
                                              |  |  +-----------------------------+   |
                                              |  +> |  WebDav Blobstroe           |   |
                                              |  |  |  garden container           |   |
                                              |  |  +-----------------------------+   |
                                              |  |                                    |
                                              |  |  +-----------------------------+   |
                                              |  +> |  Go Router                  |   |
                                              |     |  garden container           |   |
                                              |     +-----------------------------+   |
                        +                     |                 .34                   |
                        |            .209     |                                       |
                        |           +---------+                                       |
10.175.143.128/25       +---------> |  eth0   |     +-----------------------------+   |
                        |           +---------+     |       Bosh Director         |   |
                        +                     |     |         (process)           |   |
                                              |     +-----------------------------+   |
                                              |                                       |
                                              +---------------------------------------+
```

## Issue description

The bits-service provides public urls for uploading the bits to a blobstore for example `blobstore.10.175.143.209.nip.io` and this host could not connect from inside the VM and/or the container. From outside of the VM its accessible.

### Troubleshoot the connections

* Testing the connection to the blobstore from outside the softlayer vm (my local machine) is fine:

  ```bash
  bash$ curl blobstore.10.175.143.209.nip.io
  <html>
  ...
  ```

  The HTTP response code does not matter; we are only interested in the HTTP connection itself being successful.

* Testing the connection to the blobstore from inside vm especially from a warden container (e.g. from the router):

  The dns lookup points to the director ip which is in this case 10.175.143.209 (eth0), but behind that ip there is no http endpoint available.
  ```bash
  bash$ curl blobstore.10.175.143.209.nip.io
  curl: (7) Failed to connect to blobstore.10.175.143.209.nip.io port 80: Connection refused
  ```


* Same for using the private IP address:

  ```bash
  router/bash$ curl -k https://10.244.0.134
  curl: (7) Failed to connect to 10.244.0.134 port 443: Connection refused
  ```
  this demonstrate that all connection are going through the go router and in this case there is no http endpoint on port 80. Because the route registrar does register the blobstore public endpoint at the go router on 8080 so this is ok no worry, go router will translate this correct.
  Like next test shows.

* Testing the same connection from the router container to the blobstore container with 8080 works is fine.
  ```bash
  router/bash$ curl http://10.244.0.134:8080
  <html>
  ...
  ````
  The HTTP response code does not matter; we are only interested in the HTTP connection itself being successful.

* From one container, connecting to another container's IP address directly works fine:

  ```bash
  router/bash$ curl -k https://10.244.0.134:4443
  <html>
  <head><title>403 Forbidden</title></head>
  <body bgcolor="white">
  <center><h1>403 Forbidden</h1></center>
  <hr><center>nginx</center>
  </body>
  </html>
  ```

* The same works with another arbitrary port. started on the api conatianer.
  ```
  bash$ export PATH=/var/vcap/packages/ruby-2.4/bin:$PATH
  bash$ echo "{ test : test }" >test.json
  bash$ ruby -run -e httpd test.json -p 9092 -b 10.244.0.135
  ```
  call from blob store container
  ```
   bash$ curl 10.244.0.135:9092
   { test : test }
  ```
* Testing the connection from inside the director vm to the blobstore container behave the same like from inside the router container.
  ```
  director/bash$ curl -k http://10.244.0.134:8080
  <html>
  ...
  ```
  With the use of the blobstore service port which is registered by the router for public access.
  And this works with internal service blobstore endpoint, too.

  ```
  director/bash$$ curl -k https://10.244.0.134:4443
  <html>
  ...
  ```

## Summary

This means there is no connection possible from inside a warden container to the public interface blobstore.x.x.x.x.nip.io and behave like any other request which is executed from outside the softlayer vm.

### Differnce between the IAAS Provider
I have checked the bosh-deplyoments of virtualbox and Softlayer and the only differnce I detect is that
virtualbox provides a feature called 'NAT Network' which allows guest to guest comnunication. What that means is described [here](https://www.thomas-krenn.com/en/wiki/Network_Configuration_in_VirtualBox#overview_table_of_access_options)

### Softlayer Bosh Deployment with private only flag
I deployed a Bosh-lite on SL with only a private network interface, but this does not solve the issue. But its important to know, that we do not have to provide a public interface on Softlayer.
[commit link](https://github.com/petergtz/1-click-bosh-lite-pipeline/commit/dbba806b60e659e4f1fef82d4b19268d958c3eae)

Here is summery of all the links I used for softlayer-cpi related research.

* https://github.com/cloudfoundry/docs-bosh/blob/master/softlayer-cpi.html.md.erb
* https://bosh.io/docs/softlayer-cpi.html#networks
* https://bosh.io/docs/bosh-lite.html
* https://bosh.io/docs/softlayer-cpi.html#networks
* https://bosh.io/docs/softlayer-cpi.html#cloud-config
* https://github.com/cloudfoundry/bosh-deployment/blob/master/virtualbox/outbound-network.yml
* https://github.com/cloudfoundry/bosh-softlayer-cpi-release/blob/master/docs/deploy_dynamic_ip_director_with_bosh-deployment.md
* https://github.com/bluebosh/bosh-deployment/tree/softlayer


### Garden Release
I also compared garden release from bosh-lite on virtual box with the deployment on Softlayer, but I did not found the any difference, which solves our issue. Here are the collection of links I used for research.

* https://github.com/cloudfoundry/garden-runc-release/blob/develop/docs/opsguide.md
* https://github.com/cloudfoundry/cf-networking-release/blob/develop/docs/configuration.md
* https://github.com/cloudfoundry-attic/ducati-release/blob/master/jobs/ducati/spec
* https://github.com/cloudfoundry/guardian/blob/0984e8accf7ccc5564ce64d23f4fe8ec1af1e728/kawasaki/config_creator.go
* https://github.com/cloudfoundry/guardian/blob/a65ff1026f922fd2342e23341cfcf2f8e1518f61/guardiancmd/command.go#L244
* https://github.com/cloudfoundry/guardian/blob/a65ff1026f922fd2342e23341cfcf2f8e1518f61/guardiancmd/command.go
* https://github.com/cloudfoundry/garden-runc-release/blob/develop/jobs/garden/templates/config/config.ini.erb
* https://github.com/cloudfoundry/guardian/tree/master/guardiancmd


### TODO

- [ ] Thing try to log dropped events in iptables Masquared (The only difference I found was the outbound network in virtual box )
- [ ] local link ip is aliased to eth0 (One interface to ip aliases)
  add the go router IP to the eth0 [interface as a alias](https://www.cyberciti.biz/faq/linux-creating-or-adding-new-network-alias-to-a-network-card-nic/).
- [ ] Find a solution, how is it possible to create a overlay network on softlayer, which behave like the nat-network on virtualbox does.

### Troubleshooting Command

List NAT Table:
```
bash$ iptables -t nat -L -n -v
```
```
  Chain PREROUTING (policy ACCEPT 25981 packets, 1301K bytes)
   pkts bytes target     prot opt in     out     source               destination
  31402 1620K w--prerouting  all  --  *      *       0.0.0.0/0            0.0.0.0/0
      4   256 DNAT       tcp  --  !w+    *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 /*   bosh-warden-cpi-1ecb82be-079e-48a6-6011-d6127e0616a9 */ to:10.244.0.34:80
    356 21360 DNAT       tcp  --  !w+    *       0.0.0.0/0            0.0.0.0/0            tcp dpt:443 /*   bosh-warden-cpi-1ecb82be-079e-48a6-6011-d6127e0616a9 */ to:10.244.0.34:443

  Chain w--postrouting (1 references)
   pkts bytes target     prot opt in     out     source               destination
     31  2159 MASQUERADE  all  --  *      *       10.244.0.0/20       !10.244.0.0/20        /*   97fb2d13-5095-4d7b-51ed-d9fa1d382f49 */
```
show route table:
````
bash$ route -n
route table

Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.175.143.129  0.0.0.0         UG    0      0        0 eth0
10.0.0.0        10.175.143.129  255.0.0.0       UG    0      0        0 eth0
10.175.143.128  0.0.0.0         255.255.255.128 U     0      0        0 eth0
10.244.0.0      0.0.0.0         255.255.240.0   U     0      0        0 wbrdg-0af40000
161.26.0.0      10.175.143.129  255.255.0.0     UG    0      0        0 eth0
````