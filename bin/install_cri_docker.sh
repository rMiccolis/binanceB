#!/bin/bash

###############################################################################
# Install the docker cri (Container Runtime Interface)
#https://github.com/Mirantis/cri-dockerd/releases this is the release package
echo -e "${LBLUE}Installing the docker cri (Container Runtime Interface)${WHITE}"
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd-0.3.1.amd64.tgz

sudo tar -xvf cri-dockerd-0.3.1.amd64.tgz

cd cri-dockerd/
mkdir -p /usr/local/bin

sudo install -o root -g root -m 0755 ./cri-dockerd /usr/local/bin/cri-dockerd

# check these file from https://github.com/Mirantis/cri-dockerd/tree/master/packaging/systemd
# edit line 'ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd://'
# into: 'ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin='

sudo tee /etc/systemd/system/cri-docker.service << EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket
[Service]
Type=notify
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=
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

sudo tee /etc/systemd/system/cri-docker.socket << EOF
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

sudo systemctl daemon-reload

sudo systemctl enable cri-docker.service

sudo systemctl enable --now cri-docker.socket

###############################################################################