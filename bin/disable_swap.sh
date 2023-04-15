#!/bin/bash

# permanently disable swap:
# find the name of the swap partition to mask
swap_disk_name=$(systemctl --type swap | awk 'NR==2{print $1}')
if [[ $swap_disk_name == dev-*.swap ]];
then
systemctl mask $swap_disk_name
systemctl daemon-reload
echo "disk name found: " $swap_disk_name
fi

# or run this command:
# sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
# sudo swapoff -a
# sudo mount -a