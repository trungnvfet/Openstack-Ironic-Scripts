#!/bin/bash

export NODE_NAME=bm
export NODE=$(ironic node-list | grep $NODE_NAME | awk '{ print $2 }')

ironic node-set-maintenance $NODE on
ironic --ironic-api-version 1.16 node-set-provision-state $NODE abort
ironic node-set-maintenance $NODE off
ironic node-set-provision-state $NODE manage

wait

echo "Delete BM Node Now"

openstack baremetal node delete $NODE

echo "===== Check node status ==="
openstack baremetal node list
openstack barematal node show bm
