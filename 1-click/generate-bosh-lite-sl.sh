password=$(lpass show "Shared-Flintstone/Softlayer BOSH director" --password --sync=no)
sl_username=$(lpass show "Shared-Flintstone/Softlayer API Key" --username --sync=no)
api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no)
public_vlan_id=$(lpass show --sync=no  "Shared-Flintstone/Softlayer Properties" --notes | grep sl_vlan_public | tr -d ' ' | cut -d ':' -f 2)
private_vlan_id=$(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes | grep sl_vlan_private | tr -d ' ' | cut -d ':' -f 2)
datacenter=$(lpass show --sync=no "Shared-Flintstone/Softlayer Properties" --notes | grep sl_datacenter | tr -d ' ' | cut -d ':' -f 2)

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi.yml \
    -v mbus_bootstrap_password=$password \
    -v internal_ip=127.0.0.1 \
    -v sl_vm_domain=flintstone.ams \
    -v sl_vm_name_prefix=bosh-lite1 \
    -v sl_vlan_public=$public_vlan_id \
    -v sl_vlan_private=$private_vlan_id \
    -v sl_datacenter=$datacenter \
    -v sl_username=$sl_username \
    -v sl_api_key=$api_key \
    -v nats_password=$password \
    -v blobstore_agent_password=$password \
    -v blobstore_director_password=$password \
    -v postgres_password=$password \
    -v director_name=bosh \
    -v admin_password=$password \
    -v hm_password=$password \
    -o ~/workspace/bosh-deployment/bosh-lite.yml \
    -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
    -o operations/change-to-single-dynamic-network-named-default.yml \
    -o operations/change-cloud-provider-mbus-host.yml \
    -o operations/make-it-work-again-workaround.yml \
    > bosh-generated-with-stock.yml

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o operations/softlayer-cpi.yml \
    -v mbus_bootstrap_password=$password \
    -v internal_ip=127.0.0.1 \
    -v softlayer_domain=flintstone.ams \
    -v sl_vlan_public=$public_vlan_id \
    -v sl_vlan_private=$private_vlan_id \
    -v sl_datacenter=$datacenter \
    -v director_vm_prefix=bosh-lite1 \
    -v softlayer_username=$sl_username \
    -v softlayer_api_key=$api_key \
    -v nats_password=$password \
    -v blobstore_agent_password=$password \
    -v blobstore_director_password=$password \
    -v postgres_password=$password \
    -v director_name=bosh \
    -v admin_password=$password \
    -v hm_password=$password \
    -o ~/workspace/bosh-deployment/bosh-lite.yml \
    -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
    -o operations/change-to-single-dynamic-network-named-default.yml \
    -o operations/make-it-work-again-workaround.yml \
    > bosh-generated.yml

# https://github.com/sahilm/yamldiff
yamldiff --file1 bosh-generated.yml --file2 bosh-generated-with-stock.yml
