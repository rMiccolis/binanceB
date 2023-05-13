#!/bin/bash

# permanently disable swap:
# find the name of the swap partition to mask
echo "Finding the name of the swap partition to mask..."
swap_disk_name=$(systemctl --type swap | awk 'NR==2{print $1}')
echo "Swap disk name found: " $swap_disk_name
if [[ $swap_disk_name == *swap* ]];
then
sudo systemctl mask $swap_disk_name # sudo systemctl unmask $swap_disk_name to restore swap
sudo systemctl daemon-reload
echo "Swap disk $swap_disk_name masked"
echo "Saving $swap_disk_name to file /home/$USER/swap_file_name to restore swap"
# save $swap_disk_name to file to restore swap
cat << EOF | sudo tee /home/$USER/swap_file_name > /dev/null 2>&1
$swap_disk_name
EOF
fi
echo "Disabling swap for this session (no reboot needed)..."
sudo swapoff -a

# or run this command:
# sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
# sudo swapoff -a
# sudo mount -a