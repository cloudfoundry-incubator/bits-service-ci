 # VLAN 1147, see https://control.softlayer.com/network/vlans/2071971
 # VLAN 1308, see https://control.softlayer.com/network/vlans/2071973

password=$(lpass show "Shared-Flintstone/Softlayer BOSH director" --password --sync=no)
sl_username=$(lpass show "Shared-Flintstone/Softlayer API Key" --username)
api_key=$(lpass show "Shared-Flintstone/Softlayer API Key" --password --sync=no)
public_vlan_id=$(lpass show "Shared-Flintstone/Softlayer Properties" --notes | grep softlayer_public_vlan_id | tr -d ' ' | cut -d ':' -f 2)
private_vlan_id=$(lpass show "Shared-Flintstone/Softlayer Properties" --notes | grep softlayer_private_vlan_id | tr -d ' ' | cut -d ':' -f 2)
datacenter=$(lpass show "Shared-Flintstone/Softlayer Properties" --notes | grep softlayer_datacenter | tr -d ' ' | cut -d ':' -f 2)

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o ~/workspace/bosh-deployment/softlayer/cpi.yml \
    -v mbus_bootstrap_password=$password \
    -v internal_ip=127.0.0.1 \
    -v sl_vm_domain=flintstone.ams \
    -v sl_vm_name_prefix=bosh-lite1 \
    -v softlayer_public_vlan_id=$public_vlan_id \
    -v softlayer_private_vlan_id=$private_vlan_id \
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
    -o operations/bosh-lite-network-for-stock.yml \
    > bosh-generated-with-stock.yml

bosh interpolate ~/workspace/bosh-deployment/bosh.yml \
    -o operations/softlayer-cpi.yml \
    -v mbus_bootstrap_password=$password \
    -v internal_ip=127.0.0.1 \
    -v softlayer_domain=flintstone.ams \
    -v softlayer_public_vlan_id=$public_vlan_id \
    -v softlayer_private_vlan_id=$private_vlan_id \
    -v softlayer_datacenter_name=$datacenter \
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
    -o operations/bosh-lite-network-default.yml \
    > bosh-generated.yml

# function cleanup {
#     # rm bosh-generated.yml
#     # rm bosh-warden-cpi.rendered.yml
#     rm output.yml
# }


# bosh interpolate ~/workspace/bits-service-private-config/environments/softlayer/director/bosh-warden-cpi.yml \
#     -v director_vm_prefix=bosh-lite1 -v admin_password=$password > bosh-warden-cpi.rendered.yml
yamldiff --file1 bosh-generated.yml --file2 bosh-generated-with-stock.yml

# https://github.com/sahilm/yamldiff
# yamldiff --file1 bosh-warden-cpi.rendered.yml --file2 bosh-generated.yml
# if [ -s output.yml ]; then
#     yamldiff --file1 bosh-warden-cpi.rendered.yml --file2 bosh-generated.yml
#     cleanup
#     exit 1
# fi

# cleanup
