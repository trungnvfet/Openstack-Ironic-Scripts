#!/bin/bash

echo "Starting perform RAID configuration into Bare metal Server"
sleep 10
echo "Loading ..."

echo "Preparing delete old node before running new node"
sudo systemctl restart devstack@ir-*.service
sleep 30
openstack baremetal node maintenance set bm
openstack baremetal node delete bm

echo "Exporting Node name of Bare metal Server"
export NODE_NAME=bm
echo "Exporting Driver name of Bare metal Server"
export DRIVER_NAME=irmc
echo "Exporting IP address of Bare metal Server"
export IRMC_IP=10.0.0.10
echo "Exporting iRMC account of Bare metal Server"
export IRMC_USERNAME=admin
export IRMC_PASSWORD=admin
echo "Gathering MAC address of Bare metal Server"

#Operator must put BM_MAC (LAN 1 or LAN2) into script
echo "Let put your BM_MAC on Bare Metal Here: "
export BM_MAC=90:1B:0E:0F:FF:9A

echo "Exporting chassis info of Bare metal Server"
export CHASSIS_NAME=ironic
export CHASSIS_ID=$(ironic chassis-list | grep $CHASSIS_NAME | awk '{ print $2 }')

echo "CREATING node now"
ironic node-create -d $DRIVER_NAME --chassis_uuid $CHASSIS_ID -n $NODE_NAME
export NODE=$(ironic node-list | grep $NODE_NAME | awk '{ print $2 }')
ironic port-create -n $NODE -a $BM_MAC

echo "UPDATING node now"
ironic node-update $NODE add driver_info/ipmi_username=$IRMC_USERNAME driver_info/ipmi_password=$IRMC_PASSWORD driver_info/ipmi_address=$IRMC_IP driver_info/irmc_username=$IRMC_USERNAME driver_info/irmc_password=$IRMC_PASSWORD driver_info/irmc_address=$IRMC_IP driver_info/ipmi_terminal_port=10000 driver_info/irmc_port=80
ironic node-update $NODE add properties/capabilities='boot_mode:bios'
ironic node-update $NODE add properties/memory_mb='32768' properties/cpu_arch='x86_64' properties/local_gb='1000' properties/cpus='8'

echo "UPDATING kernel and ramdisk info ..."
export DEPLOY_KERNEL=$(glance image-list | grep ir-deploy-pxe_irmc.kernel | awk '{ print $2 }')
export DEPLOY_RAMDISK=$(glance image-list | grep ir-deploy-pxe_irmc.initramfs | awk '{ print $2 }')
ironic node-update $NODE add driver_info/deploy_ramdisk=$DEPLOY_RAMDISK driver_info/deploy_kernel=$DEPLOY_KERNEL

nova hypervisor-stats
sleep 45
nova hypervisor-stats
echo "Checking node bm before create RAID configuration"
openstack baremetal node show bm
echo "Checking Kernel and Ramdisk in Node info"
export Check_None=""

if [[ ${#DEPLOY_KERNEL} -eq ${#Check_None} ]]
then
    echo "Node deployment need to update kernel"
    return
elif [[ ${#DEPLOY_RAMDISK} -eq ${#Check_None} ]]
then
    echo "Node deployment need to update ramdisk"
    return
echo "Node are ready for deploying with baremetal server"
fi

echo "Adding raid config into Node and preparing to perform manual clean for RAID configuration"
openstack baremetal node set bm --target-raid-config target_raid_cfg.json
openstack baremetal node manage bm

echo "Running manual clean to create RAID configuration now"
openstack baremetal node clean bm --clean-steps clean_raid.json

echo "Drink a coffee cup and wait until finish ..."

