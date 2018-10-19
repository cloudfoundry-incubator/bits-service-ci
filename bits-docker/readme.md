# How to create a new Eirini.tar version

## generate eirnifs.tar

clone the eirini project into your `~/workspace` and go into the eirini-release

```shell
bash$ git clone git@github.com:cloudfoundry-incubator/eirini-release.git
bash$ cd eirini-release
```
This script generates a eirini.tar file in `~/workspace/eirini-release`

```shell
bash$ ./scripts/buildfs.sh
```

## Upload eirnifs to cos bucket eirini-resouces

Before you upload a new tar check the latest version of the eirinifs.tar in the bucket
You can check this with this cmd or look in the WebConsole
```shell
bash$ ./upload_to_object_store.sh -i | grep -i "eirinifs_v[0-9].[0-9].[0-9].tar"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>eirini-resources</Name><Prefix></Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><Delimiter></Delimiter><IsTruncated>false</IsTruncated><Contents><Key>eirinifs_v0.0.1.tar</Key><LastModified>2018-10-19T10:44:49.252Z</LastModified><ETag>&quot;ca0edcf75779826f72810ea1b594a88b&quot;</ETag><Size>923409920</Size><Owner><ID>c09772fe-a6f0-489f-b6eb-f92aa305e656</ID><DisplayName>c09772fe-a6f0-489f-b6eb-f92aa305e656</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>eirinifs_v0.0.2.tar</Key><LastModified>2018-10-19T11:08:44.688Z</LastModified><ETag>&quot;ca0edcf75779826f72810ea1b594a88b&quot;</ETag><Size>923409920</Size><Owner><ID>c09772fe-a6f0-489f-b6eb-f92aa305e656</ID><DisplayName>c09772fe-a6f0-489f-b6eb-f92aa305e656</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>

```

Upload the latest `eirinifs.tar` with this command
```shell
./upload_to_object_store.sh -v 0.0.3
[INFO] Do authenticate
[INFO] Succesful authenticated!
[INFO] Start upload file eirinifs_v=0.0.3.tar ...
                                                                           1.0%
```
