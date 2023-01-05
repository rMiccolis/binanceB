DOCKER APPLICATION SETUP:

create docker server build: docker build -t server -f server.dockerfile .
create docker client build: docker build -t client -f client.dockerfile .

run docker server build: docker run --rm --name server -d -p 3000:3000 server
run docker client build: docker run --rm --name client -d -p 8081:80 client

create docker volume: docker volume create --name mongodb_volume

create docker mongodb build: docker run --rm --name mongodb -d -p 27018:27017 -v mongodb_volume:/data/db mongo


Set vm resolution to full HD:

1. Open a Terminal.
2. Enter sudo nano /etc/default/grub
3. Alter the line starting with GRUB_CMDLINE_LINUX_DEFAULT to add the resolution setting. In my case, this was GRUB_CMDLINE_LINUX_DEFAULT="quiet splash     video=hyperv_fb:1920x1200"
3. Alter the line starting with GRUB_CMDLINE_LINUXT to add the resolution setting. In my case, this was GRUB_CMDLINE_LINUX="quiet splash video=hyperv_fb:1920x1200"
4. Run sudo update-grub.
5. Shut down the VM.
6. Start the VM again.

vm instructions:
