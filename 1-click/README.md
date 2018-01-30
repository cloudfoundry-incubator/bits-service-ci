# 1-Click Bosh-Lite Pipelines

## Prerequisites:

Make sure you have the following 2 git repos in `~/workspace`:
- https://github.com/cloudfoundry/bits-service-private-config
- https://github.com/petergtz/1-click-bosh-lite-pipeline

## How to create a new bosh-lite in SL Concourse management pipeline:

```bash
./set-pipeline.sh bosh-lite-name
```

where `bosh-lite-name` should be the name of the bosh-lite Softlayer VM. A `-bosh-lite` suffix is automatically appended to that name. So e.g.:

```bash
./set-pipeline.sh pego
```

would create a bosh-lite with name `pego-bosh-lite` together with a Concourse pipline with name `pego-bosh-lite`.