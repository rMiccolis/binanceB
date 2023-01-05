# binanceB

Set vm resolution to full HD:
1. Open a Terminal.
2. Enter sudo nano /etc/default/grub
3. Alter the line starting with GRUB_CMDLINE_LINUX_DEFAULT  to add the resolution setting. In my case, this was GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=hyperv_fb:1920x1200"
4. Alter the line starting with GRUB_CMDLINE_LINUXT to add the resolution setting. In my case, this was GRUB_CMDLINE_LINUX="quiet splash video=hyperv_fb:1920x1200"
5. Run sudo update-grub.
6. Shut down the VM.
7. Start the VM again.

vm instructions:
