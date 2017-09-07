#!/bin/bash

echo "----------------STARTING NOW-----------------------"

echo "Running ovs_bridge.sh to create br-*"

source ovs_bridge.sh

wait

echo "=======EXPORTING bm parameters====="

export NODE_NAME=bm
export DRIVER_NAME=pxe_irmc
export IRMC_IP=10.0.0.10
export IRMC_USERNAME=admin
export IRMC_PASSWORD=admin

echo "Export BM MAC from TIEN-San"
export BM_MAC=90:1B:0E:0F:FF:9A
export CHASSIS_NAME=ironic
export CHASSIS_ID=$(ironic chassis-list | grep $CHASSIS_NAME | awk '{ print $2 }')

wait

echo "---------CREATING Ironic NODE--------------"
ironic node-create -d $DRIVER_NAME --chassis_uuid $CHASSIS_ID -n $NODE_NAME

wait

export NODE=$(ironic node-list | grep $NODE_NAME | awk '{ print $2 }')

echo "---------CREATING Ironic PORT--------------"
ironic port-create -n $NODE -a $BM_MAC

wait

echo "---------UPDATING Ironic NODE--------------"
ironic node-update $NODE add driver_info/ipmi_username=$IRMC_USERNAME driver_info/ipmi_password=$IRMC_PASSWORD driver_info/ipmi_address=$IRMC_IP driver_info/irmc_username=$IRMC_USERNAME driver_info/irmc_password=$IRMC_PASSWORD driver_info/irmc_address=$IRMC_IP driver_info/ipmi_terminal_port=10000

wait

ironic node-update $NODE add properties/capabilities='boot_mode:bios'

wait

ironic node-update $NODE add properties/memory_mb='32768' properties/cpu_arch='x86_64' properties/local_gb='1000' properties/cpus='8'

wait

export DEPLOY_KERNEL=$(glance image-list | grep ir-deploy-pxe_irmc.kernel | awk '{ print $2 }')
export DEPLOY_RAMDISK=$(glance image-list | grep ir-deploy-pxe_irmc.initramfs | awk '{ print $2 }')

ironic node-update $NODE add driver_info/deploy_ramdisk=$DEPLOY_RAMDISK driver_info/deploy_kernel=$DEPLOY_KERNEL

wait

nova hypervisor-stats

wait 1200

echo "---------MAPPING CELL--------------"
nova-manage cell_v2 simple_cell_setup

wait

echo "========Launch Instance======="
export NODE_NAME=bm
export NET_ID=$(neutron net-list | grep 'private' | awk '{ print $2 }')
export NET_ID2=$(neutron net-list | grep 'private2' | awk '{ print $2 }')
export IMAGE_ID=$(glance image-list | grep 'uec' | awk '{ print $2 }' | head -n1)

echo "==============Let's run following command 'nova boot --nic net-id=$NET_ID --flavor baremetal --image $IMAGE_ID $NODE_NAME'==============="

echo "Mapping cell and install python-scciclient"

nova-manage cell_v2 simple_cell_setup
wait
sudo pip install "python-scciclient>=0.5.0" pysnmp
wait

echo "FINISH===========FINISH====================FINISH==================FINISH=======================FINISH"

echo "CHECKING AGAIN `nova hypervisor-stats` "
nova hypervisor-stats

echo "CHECKING `openstack baremetal node list` and `openstack baremetal node show bm` for bios is wait "
echo "Need to run `ironic node-update $NODE add properties/capabilities='boot_mode:bios'` again"
