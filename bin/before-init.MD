
# Virtual machine operations

#tested versions:
- Ubuntu version: 20.04.6 LTS
- kernel version: 5.4.0-146-generic
- docker version: /23.0.3
- kubernetes version 1.26 / 1.27

## Choose a linux distro which makes use of systemd as init service

After creating VM with a linux distro:
- disable windows secure boot
- set at least 2 cpus
- set at least 2048MB or RAM (if you have not enough set a max RAM usage tipically 4096MB)
- set static MAC address and assign a fixed ip address to it from the router (ex MAC address: 00 15 5D 38 01 30 and assign it this example ip address: 192.168.1.200)

# OS Ooerations
- grant sudo permissions to the system user account to which connect through ssh
- install an ssh server
- disable swap partition if enabled