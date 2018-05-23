# Check console
ipmitool -I lanplus -H 10.0.0.10 -U admin -P admin sol activate

# Fix Cinder volume
- loop
- pvcreate
- pvdisplay
- vgcreate

# ERROR cinder.service [-] Manager for service cinder-volume stack-VirtualBox@lvmdriver-1 is reporting problems, not sending heartbeat. Service will appear "down".
# stack-volumes-lvmdriver-1
## allocate file 20 GB
fallocate -l 20G lvm_cinder

## Create a Loop Device
sudo losetup --find --show lvm_cinder /dev/loop0
## PV create
sudo pvcreate /dev/loop0 
## VG create
sudo vgcreate stack-volumes-lvmdriver-1 /dev/loop0
## restart Cinder

# MOUNT between VM and Host via VirtualBox
sudo mount -t vboxsf Images ~/Images -o gid=1000,uid=1000

