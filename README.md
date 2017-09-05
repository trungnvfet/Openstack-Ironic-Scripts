# F_ironic_bm_script
Implement BM nodes and Instance Nova

Lets run ``source instance_node_create.sh`` along with some following commande.

``$ source /etc/environment``

** Delete `clean wait` node:

- Running script to change `clean wait` into `manageble`

``$ source bm_node_delete.sh``

- Delete current instance via dashboard/cli
- Delete current node via cli

``$ openstack baremetal node delete $NODE

** Create BM node:

``source instance_node_create.sh``
