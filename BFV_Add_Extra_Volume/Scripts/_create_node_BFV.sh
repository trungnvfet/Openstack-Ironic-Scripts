#!//bin/bash

#sudo systemctl restart devstack@ir-cond.service
export BM_MAC=90:1B:0E:B0:AC:83
#export BM_MAC=90:1B:0E:0F:FF:9A
export NODE_NAME=bm
export DRIVER_NAME=pxe_irmc
export IRMC_IP=10.0.0.10
export IRMC_USERNAME=admin
export IRMC_PASSWORD=admin
export DEPLOY_KERNEL=$(glance image-list | grep ir-deploy-pxe_irmc.kernel | awk '{ print $2 }')
export DEPLOY_RAMDISK=$(glance image-list | grep ir-deploy-pxe_irmc.initramfs | awk '{ print $2 }')

ironic node-create -d $DRIVER_NAME -n $NODE_NAME
export NODE_ID=$(ironic node-list | grep $NODE_NAME | awk '{ print $2 }')
ironic port-create -n $NODE_ID -a $BM_MAC
ironic node-update $NODE_ID add driver_info/ipmi_username=$IRMC_USERNAME driver_info/ipmi_password=$IRMC_PASSWORD driver_info/ipmi_address=$IRMC_IP driver_info/ipmi_terminal_port=10000
ironic node-update $NODE_ID add properties/capabilities='boot_mode:bios'
ironic node-update $NODE_ID add properties/memory_mb='32768' properties/cpu_arch='x86_64' properties/local_gb='1000' properties/cpus='8'
ironic node-update $NODE_ID add driver_info/irmc_address=$IRMC_IP driver_info/irmc_username=$IRMC_USERNAME driver_info/irmc_password=$IRMC_PASSWORD  
ironic node-update $NODE_ID add driver_info/deploy_ramdisk=$DEPLOY_RAMDISK driver_info/deploy_kernel=$DEPLOY_KERNEL
openstack baremetal node set $NODE_ID --resource-class baremetal

# Boot from volume
openstack baremetal node set --storage-interface cinder $NODE_ID
openstack baremetal node set --property capabilities=iscsi_boot:True $NODE_ID
openstack baremetal volume connector create --node $NODE_ID --type iqn --connector-id iqn.2017-10.org.openstack.$NODE_ID
openstack baremetal volume connector create --node $NODE_ID --type iqn --connector-id iqn.2017-11.org.openstack.$NODE_ID

# End Boot from volume
ironic node-set-provision-state bm manage
ironic node-set-provision-state bm provide
# disk-image-create ubuntu dhcp-all-interfaces devuser cloud-init-datasources iscsi-boot -o $IMAGE_NAME
openstack volume list
openstack networks list
# Check volumes and network ID.
# openstack server create --volume 494e4184-e697-473b-a363-8cd9f6f8dc76 --flavor baremetal --block-device-mapping sdb=7c9c710a-2448-4a66-8aff-71c760a6903f --config-drive True --network 54d34349-c10d-4dda-9731-7acb8d91945b bm


openstack baremetal node validate $NODE_ID | grep -E '(power|management)\W*False'

openstack hypervisor stats show

nova-manage cell_v2 discover_hosts

#export IMAGE_ID=$(glance image-list | grep 'u-16' | awk '{ print $2 }' | head -n1)
#export NET_ID=$(neutron net-list | grep 'private' | awk '{ print $2 }')
#nova boot --nic net-id=$NET_ID --flavor baremetal --image $IMAGE_ID $NODE_ID

