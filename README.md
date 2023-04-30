
# Virtual machine operations

#tested versions:
- Ubuntu version: 20.04.6 LTS
- kernel version: 5.4.0-146-generic
- docker version: /23.0.3
- kubernetes version 1.26

## Choose a linux distro which makes use of systemd as init service

After creating VM with a linux distro:
- disable windows secure boot
- set at least 2 cpus
- set at least 2048MB or RAM (if you have not enough set a max RAM usage tipically 4096MB)
- set static MAC address and assign a fixed ip address to it from the router (ex MAC address: 00 15 5D 38 01 30 and assign it this example ip address: 192.168.1.200)

# Mandatory OS OPerations before executing 'infrastructure_setup.sh'
- install an ssh server
- copy ssh public key into .ssh authorized file of the remote host to use ssh connection without password prompt
- enable passwordless sudo to the system user account to which connect through ssh (in sudoers file append using sudo visudo: $USER ALL=(ALL) NOPASSWD: ALL) [Where $USER is your username on your system ]

## EXAMPLE:
### FOR EACH REMOTE HOST EXECUTE THESE INSTRUCTIONS!
#### ('m1' is the host that will have the master role inside the cluster)
#### ('w1' is the host that will have the worker role inside the cluster)
```
# copy ssh public key into .ssh authorized file of the remote host to use ssh connection without password prompt (to be done for all hosts)
scp C:\Users\ROB\.ssh\id_rsa.pub m1@m1:/home/m1/.ssh/authorized_keys
ssh m1@m1
ssh-keygen
exit
scp m1@m1:/home/m1/.ssh/id_rsa.pub E:\Download\

scp C:\Users\ROB\.ssh\id_rsa.pub w1@w1:/home/w1/.ssh/authorized_keys
scp E:\Download\id_rsa.pub w1@w1:/home/w1/.ssh/authorized_keys

# copy infrastructure_setup.sh into the master remote host and execute it
<!-- scp E:\Desktop\binanceB\bin\infrastructure_setup.sh m1@m1:/home/m1/ -->

# clone the repo into master remote host
scp -r E:\Desktop\binanceB m1@m1:/home/m1/

# copy main_config.json to master remote host to for application configuration
scp E:\Download\main_config.json m1@m1:/home/m1/

# ssh into all remote hosts and set passwordless sudo prompt for remote host username
ssh m1@m1
cat << EOF | sudo tee -a /etc/sudoers > /dev/null
$USER ALL=(ALL) NOPASSWD: ALL
EOF

exit

ssh w1@w1
cat << EOF | sudo tee -a /etc/sudoers > /dev/null
$USER ALL=(ALL) NOPASSWD: ALL
EOF

exit

```

### Run infrastructure_setup.sh script on the master remote host
```
ssh m1@m1
chmod -R u+x ./binanceB
sed -i -e 's/\r$//' ./binanceB/bin/infrastructure_setup.sh
./infrastructure_setup.sh -u docker_username -p docker_password -c "/home/m1/main_config.json"
```

# -------------------------------------------------------------------------------------------------------------
# DOCKER APPLICATION SETUP:

1. position in the root directory (./binanceB)

2.  create docker build:
    ```
    sudo docker build -t rmiccolis/binanceb_nodejs_server -f ./server/server.dockerfile ./server/
    ```
    create docker client build:
    ```
    sudo docker build -t rmiccolis/binanceb_vuejs_client -f ./client/client.dockerfile ./client/
    ```
### if debug is needed while building:
#### create build and debug (example):
    ```
    sudo docker build --no-cache --progress=plain -t rmiccolis/binanceb_vuejs_client -f ./client/client.dockerfile ./client/
    ```
1. push images to Docker Hub
    ```
    sudo docker push rmiccolis/binanceb_nodejs_server:NOMETAG
    sudo docker push rmiccolis/binanceb_vuejs_client:NOMETAG
    ```

# Instructions to run on ('plain') docker
```
run docker server build: docker run --rm --name server -d -p 3000:3000 server
run docker client build: docker run --rm --name client -d -p 8081:80 client

# create docker volume: 
docker volume create --name mongodb_volume

# create docker mongodb build: 
docker run --rm --name mongodb -d -p 27018:27017 -v mongodb_volume:/data/db mongo
```
