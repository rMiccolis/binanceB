# BinanceB

Cloud-like application, with educational purposes, for cryptocurrency trading served via browser and Android application. Based on microservices architecture, it implements the Infrastructure as Code process allowing the generation of virtual machines and creation of a Kubernetes cluster on which is automatically installed the application. \
This project is intended for educational purposes and to learn something new about IaC (Infrastructure as Code) and cloud development, for this reason some choices may result unusual because the project tries to simulate the cloud behavior but on bare metal. This choice is made to handle costs, given that the development of this project is performed in spare time (non-working time) and could take many months, so picking a real cloud provider could be very expensive.\
Because of this, the projects offers a PowerShell script that creates linux (ubuntu cloud image) VMs (with hyper-v as hypervisor) on the fly and configures them using cloud-init.

There are 5 main scripts that create and configure all the infrastructure and both need a configuration yaml file (main_config.yaml) to be executed (an example is found at main_config.example.yaml)

**Script Description:**

- **infrastructure/windows/generate_hyperv_vms.ps1:** This is the script that manages the generation and configuration of ubuntu virtual machines. The script makes use of cloud-init in order to give the initial configuration to VMs. At the end of the script, it opens a cmd instance and copies to clipboard the command to be pasted in in order to start the start.sh script.
- **infrastructure/start.sh:** This script is excecuted on the main VM and performs all the tasks to create a kubernetes cluster and install the client-server application on it.
- **bin/manage_docker_images.sh:** This script is usefull when an update of server or client (or both) docker image is needed.
- **bin/setup_worker_nodes.sh:** This script is usefull to join a new node to the cluster (control plane or worker) and configure it (install docker, kubernetes, ecc...)
- **bin/add_wireguard_peer.sh:** Run this script to generate a Wireguard peer configuration. It prints out the qr code to be scanned by Android or IOS app to join the vpn.

## INSTRUCTION TO RUN THE INFRASTRUCTURE SETUP

## Virtual machine operations

### tested versions

- Ubuntu version: focal-server-cloudimg-amd64 (20.04 LTS) - jammy-server-cloudimg-amd64 (22.04 LTS)
- Kernel version: Linux 5.4.0-148-generic
- Docker version: 23.0.5
- Cri-dockerd version: 0.3.4
- Kubernetes version 1.27.4

After creating VM with a linux distro:

- Disable windows secure boot
- Set minimum 30GB of disk space
- Set at least 2 cpus
- Set at least 2048MB or RAM (if you have not enough set a max RAM usage, tipically 4096MB)
- Set static MAC address and assign a fixed ip address to it from the router (EX: MAC address: 00 15 5D 38 01 30 and assign it to ip address 192.168.1.200)

## Mandatory OS OPerations before executing './infrastructure/start.sh' (follow these steps in the example paragraph)

- **Choose a linux distro which makes use of systemd as init service**
- Install an ssh server
- Add all cluster partecipating hosts to the hosts file
- Copy ssh public key into .ssh authorized_keys file of the remote host to use ssh connection without password prompt
- Enable passwordless sudo to the system user account to which connect through ssh (in sudoers file append using sudo visudo: $USER ALL=(ALL) NOPASSWD: ALL) [Where $USER is your username on your system ]
- Open 51820 port to let application and mongodb database to be reachable. This is the Wireguard VPN port.
- Create a [docker access token](https://docs.docker.com/docker-hub/access-tokens/) (to be provided into main_config.yaml)
- Create the client docker repository
- Create the server docker repository

## Launch script for auto creating VM on hyper-v (windows) and setup and boot all the application

### The script makes use of cloud-init to give a starting linux configuration (ssh server, ssh key-pairs, remove psw to execute sudo commands, loads main_config.yaml and pulls the github repo)

**IMPORTANT:**
TO LET THIS SCRIPT WORK, YOU **MUST**:

- Download ADK - https://learn.microsoft.com/it-it/windows-hardware/get-started/adk-install. You only need to install the deployment tools once in the default location. Oscdimg is used to write the CIDATA image (containing meta-data and user-data files) for cloud init as a ISO 9660 image
- Download qemu-img: http://www.cloudbase.it/qemu-img-windows/. Quemu is used to convert ubuntu cloud-image to a virtual hard drive to be used by virtual machines
- **PICK A CLOUD-IMAGE ISO FOR YOUR LINUX DISTRO (ex: [focal-server-cloudimg-amd64 download link](https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img) )**
- have the ssh key pairs of the host you're launching all the infrastructure from (used to access and setup all other hosts. The host is your host that has access to github repo and from which the script will be launched) at the default path C:\Users\USERNAME\\.ssh\ . This key must have access to github repository

Launch generate_hyperv_vms.ps1:
Input parameter:
- config_file_path => This is the path to the configuration file and MUST be called "main_config.yaml". This is the yaml file to configure virtual machines and application (example [HERE](https://github.com/rMiccolis/binanceB/blob/master/main_config.example.yaml))

```powershell
powershell.exe -noprofile -executionpolicy bypass -file "E:\Desktop\binanceB\infrastructure\windows\generate_hyperv_vms.ps1" -config_file_path "E:\Download\main_config.yaml"
```


### SINGLE EXECUTABLE SCRIPTS

Is possible to launch 2 standalone scripts:

- bin/setup_worker_nodes.sh   => Run this script to join a new node to the cluster (control plane or worker)
- bin/manage_docker_images.sh => Run this script to build and deploy client and server images when you need to apply changes to server or client code
- bin/add_wireguard_peer.sh => Run this script to generate a Wireguard peer configuration. It prints out the qr code to be scanned by Android or IOS app to join the vpn.

--------------------------------------------

## MANUAL STARTUP EXAMPLE (NOT RECOMMENDED!)

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

**Copy main_config.yaml to master remote host to for application configuration:**

```bash
scp E:\Download\main_config.yaml m1@m1:/home/m1/
ssh m1@m1 "chmod -R u+x ./main_config.yaml"
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
./infrastructure/start.sh -u docker_username -p docker_access_token -c "/home/m1/main_config.yaml"
```
