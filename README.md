# INSTRUCTION TO RUN THE INFRASTRUCTURE SETUP

## Virtual machine operations

### tested versions

- Ubuntu version: 20.04.6 LTS
- Kernel version: Linux 5.4.0-148-generic
- Docker version: /23.0.5
- Cri-dockerd version: 0.3.2
- Kubernetes version 1.27.2

After creating VM with a linux distro:

- Disable windows secure boot
- Set minimum 30GB of disk space
- Set at least 2 cpus
- Set at least 2048MB or RAM (if you have not enough set a max RAM usage tipically 4096MB)
- Set static MAC address and assign a fixed ip address to it from the router (ex MAC address: 00 15 5D 38 01 30 and assign it for example to ip address: 192.168.1.200)

## Mandatory OS OPerations before executing './infrastructure/start.sh' (follow these steps in the example paragraph)

- **Choose a linux distro which makes use of systemd as init service**
- Install an ssh server
- Add all cluster partecipating hosts to the hosts file
- Copy ssh public key into .ssh authorized_keys file of the remote host to use ssh connection without password prompt
- Enable passwordless sudo to the system user account to which connect through ssh (in sudoers file append using sudo visudo: $USER ALL=(ALL) NOPASSWD: ALL) [Where $USER is your username on your system ]

## EXAMPLE OF main_config.json (find example file in ./kubernetes/app/main_config.json.example)

{
"environment": "production", #or "development" to set master ip as cluster_public_ip (sets it as private master ip: ES: 192.168.1.200. With 'development' cluster won't be accessible from outside of the network)
"cluster_dns_name": "cluster.com",
"cluster_public_ip": "84.248.17.191",
"master_host": "m1@192.168.1.200",
"hosts": ["w1@192.168.1.201","w2@192.168.1.202"], #user_name@ip_address (ip address must be from internal interface like in this example)
"server_access_token_secret": "server_access_token_secret",
"server_refresh_token_secret": "server_refresh_token_secret",
"server_access_token_lifetime": "50",
"server_refresh_token_lifetime": "50",
"mongo_root_username": "mongorootusername",
"mongo_root_password": "mongorootpassword"
}

## Launch script for auto creating VM on hyper-v (windows)

**IMPORTANT:**
TO LET THIS SCRIPT WORK, YOU MUST PICK A CLOUD-IMAGE ISO FOR YOUR LINUX DISTRO

Launch generate_hyperv_vms.ps1:
powershell.exe -noprofile -executionpolicy bypass -file "E:\Desktop\binanceB\infrastructure\windows\generate_hyperv_vms.ps1" -config_path "E:\Download\main_config.json" -imagePath "E:\Desktop\torrent downloads\SO\focal-server-cloudimg-amd64.img" -vm_store_path "F:\VM"

## MANUAL STARTUP EXAMPLE

**EXECUTE THESE INSTRUCTIONS on host with github cloning permissions! ('m1' is the host that will have the master role inside the cluster)**
**('w1' is the host that will have the worker role inside the cluster, the others will be w2,w3 and so on)**

**Copy your ssh public key into .ssh authorized file of the remote host to use ssh connection without password prompt (## to be done for all hosts):**

```bash
scp C:\Users\ROB\.ssh\id_rsa.pub m1@m1:/home/m1/.ssh/authorized_keys
scp C:\Users\ROB\.ssh\id_rsa.pub w1@w1:/home/w1/.ssh/authorized_keys
```

**Create master and workers ssh key pairs (## to be done for all hosts):**

```bash
ssh m1@m1 "ssh-keygen -q -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
ssh w1@w1 "ssh-keygen -q -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
```

**Download master's public key:**

```bash
scp m1@m1:/home/m1/.ssh/id_rsa.pub E:\Download\
```

**Insert master's public key into workers' authorized_keys file (to be done for all workers):**

```bash
scp E:\Download\id_rsa.pub w1@w1:/home/w1/.ssh/authorized_keys
```

**Clone the repo into master remote host:**

```bash
scp -r -q E:\Desktop\binanceB m1@m1:/home/m1/
ssh m1@m1 "chmod -R u+x ./binanceB"
```

**Copy main_config.json to master remote host to for application configuration:**

```bash
scp E:\Download\main_config.json m1@m1:/home/m1/
ssh m1@m1 "chmod -R u+x ./main_config.json"
```

**Ssh into all remote hosts and set passwordless sudo prompt for remote host username (## to be done for all hosts):**

```bash
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

**Run ./infrastructure/start.sh script on the master remote host:**

```bash
./infrastructure/start.sh -u docker_username -p docker_password -c "/home/m1/main_config.json"
```
