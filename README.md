# INSTRUCTION TO RUN THE INFRASTRUCTURE SETUP
## Virtual machine operations

### tested versions:
- Ubuntu version: 20.04.6 LTS
- kernel version: Linux 5.4.0-148-generic
- docker version: /23.0.5
- cri-dockerd version: 0.3.1
- kubernetes version 1.27.1

After creating VM with a linux distro:
- disable windows secure boot
- set at least 2 cpus
- set at least 2048MB or RAM (if you have not enough set a max RAM usage tipically 4096MB)
- set static MAC address and assign a fixed ip address to it from the router (ex MAC address: 00 15 5D 38 01 30 and assign it for example to ip address: 192.168.1.200)

# Mandatory OS OPerations before executing './infrastructure/init.sh' (follow these steps in the example paragraph)
- ### Choose a linux distro which makes use of systemd as init service
- install an ssh server
- copy ssh public key into .ssh authorized_keys file of the remote host to use ssh connection without password prompt
- enable passwordless sudo to the system user account to which connect through ssh (in sudoers file append using sudo visudo: $USER ALL=(ALL) NOPASSWD: ALL) [Where $USER is your username on your system ]

## EXAMPLE OF main_config.json (find example file in ./kubernetes/app/main_config.json.example)
{
"environment": "production", #or "development" to set master ip as cluster_public_ip (sets it as private master ip: ES: 192.168.1.202. With 'development' cluster won't be accessible from outside of the network)
"cluster_dns_name": "cluster.com",
"cluster_public_ip": "84.248.17.191",
"hosts": ["w1@192.168.1.203"], #user_name@ip_address (ip address must be from internal interface like in this example)
"server_access_token_secret": "server_access_token_secret",
"server_refresh_token_secret": "server_refresh_token_secret",
"server_access_token_lifetime": "50",
"server_refresh_token_lifetime": "50",
"mongo_root_username": "mongorootusername",
"mongo_root_password": "mongorootpassword"
}

# EXAMPLE:
### EXECUTE THESE INSTRUCTIONS!
#### ('m1' is the host that will have the master role inside the cluster)
#### ('w1' is the host that will have the worker role inside the cluster, the others will be w2,w3 and so on)

##### copy ssh public key into .ssh authorized file of the remote host to use ssh connection without password prompt (## to be done for all hosts)
```

scp C:\Users\ROB\.ssh\id_rsa.pub m1@m1:/home/m1/.ssh/authorized_keys
scp C:\Users\ROB\.ssh\id_rsa.pub w1@w1:/home/w1/.ssh/authorized_keys
```

##### create master and workers ssh key pairs
```
ssh m1@m1 "ssh-keygen -q -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
ssh w1@w1 "ssh-keygen -q -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
```

##### download master's public key
```
scp m1@m1:/home/m1/.ssh/id_rsa.pub E:\Download\
```

##### insert master's public key into workers' authorized_keys file (to be done for all workers)
```
scp E:\Download\id_rsa.pub w1@w1:/home/w1/.ssh/authorized_keys
```

##### clone the repo into master remote host
```
scp -r E:\Desktop\binanceB m1@m1:/home/m1/
ssh m1@m1 "chmod -R u+x ./binanceB"
```

##### copy main_config.json to master remote host to for application configuration
```
scp E:\Download\main_config.json m1@m1:/home/m1/
ssh m1@m1 "chmod -R u+x ./main_config.json"
```

##### ssh into all remote hosts and set passwordless sudo prompt for remote host username
```
ssh w1@w1
cat << EOF | sudo tee -a /etc/sudoers > /dev/null
$USER ALL=(ALL) NOPASSWD: ALL
EOF

exit

ssh m1@m1
cat << EOF | sudo tee -a /etc/sudoers > /dev/null 2>&1
$USER ALL=(ALL) NOPASSWD: ALL
EOF

```

### Run ./infrastructure/init.sh script on the master remote host
```
./infrastructure/init.sh -u docker_username -p docker_password -c "/home/m1/main_config.json"
```