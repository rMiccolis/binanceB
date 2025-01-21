#!/bin/bash

###############################################################################
# Install the docker cri (Container Runtime Interface)
#https://github.com/Mirantis/cri-dockerd/releases this is the release package
sudo apt-get upgrade -y -q > /dev/null 2>&1

# fetch latest release from github repository
echo -e "${LBLUE}Fetching latest release from github repository...${WHITE}"
LATEST_CRI_DOCKERD_VERSION=$(sudo curl -L -s -H 'Accept: application/json' https://github.com/Mirantis/cri-dockerd/releases/latest)
LATEST_CRI_DOCKERD_VERSION=$(echo $LATEST_CRI_DOCKERD_VERSION | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

# download FIXED cri-dockerd version
# echo -e "${LBLUE}Downloading package...${WHITE}"
# FILE_NAME="cri-dockerd-0.3.1.amd64.tgz"
# RELEASE_URL="https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/$FILE_NAME"
# wget $RELEASE_URL > /dev/null 2>&1

# download latest cri-dockerd version
echo -e "${LBLUE}Downloading package...${WHITE}"
# FILE_NAME="cri-dockerd-${LATEST_CRI_DOCKERD_VERSION}-linux-amd64.tar.gz"
# RELEASE_URL="https://github.com/Mirantis/cri-dockerd/releases/download/$LATEST_CRI_DOCKERD_VERSION/$FILE_NAME"
# wget $RELEASE_URL > /dev/null 2>&1
FILE_NAME="cri-dockerd-${LATEST_CRI_DOCKERD_VERSION:1}.amd64.tgz"
echo -e "${LPURPLE}DOWNLOADING CRI-DOCKERD FILE NAME: $FILE_NAME ${WHITE}"
RELEASE_URL="https://github.com/Mirantis/cri-dockerd/releases/download/$LATEST_CRI_DOCKERD_VERSION/$FILE_NAME"
wget $RELEASE_URL > /dev/null 2>&1


# extract it
echo -e "${LBLUE}Exctracting package...${WHITE}"
sudo tar -xvf $FILE_NAME > /dev/null 2>&1

# install cri-dockerd
echo -e "${LBLUE}Installing Cri-Dockerd...${WHITE}"
cd cri-dockerd/ > /dev/null 2>&1
mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 ./cri-dockerd /usr/local/bin/cri-dockerd > /dev/null 2>&1


# edit original installed files
# check these file from https://github.com/Mirantis/cri-dockerd/tree/master/packaging/systemd
# edit line 'ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd://'
# into: 'ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni'
sudo tee /etc/systemd/system/cri-docker.service << EOF > /dev/null 2>&1
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket
[Service]
Type=notify
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/cri-docker.socket << EOF > /dev/null 2>&1
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service
[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker
[Install]
WantedBy=sockets.target
EOF

sudo systemctl daemon-reload > /dev/null 2>&1

sudo systemctl enable cri-docker.service > /dev/null 2>&1

sudo systemctl enable --now cri-docker.socket > /dev/null 2>&1

###############################################################################