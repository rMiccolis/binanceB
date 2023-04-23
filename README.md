
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
```
# copy ssh public key into .ssh authorized file of the remote host to use ssh connection without password prompt
scp C:\Users\ROB\.ssh\id_rsa.pub m1@m1:/home/m1/.ssh/authorized_keys

# ssh into remote host and set passwordless sudo prompt for remote host username
cat << EOF | sudo tee -a /etc/sudoers
$USER ALL=(ALL) NOPASSWD: ALL
EOF
```

```
# copy infrastructure_setup.sh into the master remote host and execute it
scp E:\Desktop\binanceB\bin\infrastructure_setup.sh m1@m1:/home/m1/
ssh -A m1@m1
chmod u+x ./infrastructure_setup.sh
./infrastructure_setup.sh
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
