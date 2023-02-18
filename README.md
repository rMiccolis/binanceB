*Set vm resolution to full HD:*

1. Open a Terminal.
2. Enter sudo nano /etc/default/grub
3. Alter the line starting with GRUB_CMDLINE_LINUX_DEFAULT to add the resolution setting. In my case, this was GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=hyperv_fb:1920x1200"
3. Alter the line starting with GRUB_CMDLINE_LINUXT to add the resolution setting: "GRUB_CMDLINE_LINUX=quiet splash video=hyperv_fb:1920x1200"
4. Run sudo update-grub.
5. Shut down the VM.
6. Start the VM again.

vm instructions:
1. install git: sudo apt install git
2. use the ssh key to clone project
3. git clone git@github.com:rMiccolis/binanceB.git
4. install docker: 
   1. sudo apt-get update
   2. sudo apt-get install ca-certificates curl gnupg lsb-release
   3. sudo mkdir -p /etc/apt/keyrings
   4. curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   5. echo  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   6. sudo apt-get update
   7. sudo chmod a+r /etc/apt/keyrings/docker.gpg
   8. sudo apt-get update
   9. sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
   10. sudo docker run hello-world
5. install kubernetes: (https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) (https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/)
   1. sudo apt-get update
   2. sudo apt-get install -y apt-transport-https ca-certificates curl
   3. sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
   4. echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
   5. sudo apt-get update
   6. sudo apt-get install -y kubelet kubeadm kubectl
   7. sudo apt-mark hold kubelet kubeadm kubectl
6. create cluster:
   1. sudo apt-get update
   2. sudo apt-get upgrade
   3. sudo rm /etc/containerd/config.toml
   4. sudo systemctl restart containerd
   5. sudo kubeadm init

