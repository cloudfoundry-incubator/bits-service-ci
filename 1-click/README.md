# 1-Click Bosh-Lite Pipelines

## Prerequisites:

Make sure you have the following 2 git repos in `~/workspace`:
- https://github.com/cloudfoundry/bits-service-private-config
- https://github.com/petergtz/1-click-bosh-lite-pipeline

## How to create a new bosh-lite in SL Concourse management pipeline:

```bash
./set-pipeline.sh my-pipeline-name my-pipeline-config.yml
```

Where `my-pipeline-config.yml` must contain:
```yml
meta:
  bosh-lite-name: my-bosh-lite-name
  events-git-repo: git@github.com:cloudfoundry-incubator/bits-service-ci.git
  cf-system-domain: my-bosh-lite-name.dynamic-dns.net
```
