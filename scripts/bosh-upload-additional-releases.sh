#!/bin/bash -ex

diego_version=$(curl -s https://github.com/cloudfoundry/cf-release/releases | sed -n 's/.*Diego release <a href="https:\/\/github.com\/cloudfoundry\/diego-release\/tree\/v\(.*\)">.*/\1/p' | head -1)
garden_runc_version=$(curl -s https://github.com/cloudfoundry/cf-release/releases | sed -n 's/.*Garden-Runc release <a href="https:\/\/github.com\/cloudfoundry\/garden-runc-release\/tree\/v\(.*\)">.*/\1/p' | head -1)
etcd_version=$(curl -s https://github.com/cloudfoundry/cf-release/releases | sed -n 's/.*etcd release <a href="https:\/\/github.com\/cloudfoundry-incubator\/etcd-release\/tree\/v\(.*\)">.*/\1/p' | head -1)
cflinuxfs2_rootfs_version=$(curl -s https://github.com/cloudfoundry/cf-release/releases | sed -n 's/.*cflinuxfs2-rootfs release <a href="https:\/\/github.com\/cloudfoundry\/cflinuxfs2-rootfs-release\/tree\/v\(.*\)">.*/\1/p' | head -1)

bosh upload release https://bosh.io/d/github.com/cloudfoundry/diego-release?v=$diego_version
bosh upload release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release?v=$garden_runc_version
bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release?v=$etcd_version
bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release?v=$cflinuxfs2_rootfs_version
