param(
[string]$config_file_path
)

# READ ALL CONFIGURATION KEYS
$config=Get-Content $config_file_path | ConvertFrom-Json

$ssh_path = "$HOME\.ssh"
$pub_key_path = "$HOME\.ssh\id_rsa.pub"

if (!(Test-Path "$HOME\.ssh\config" -PathType Leaf)) {
New-Item "$HOME\.ssh\config"
Set-Content "$HOME\.ssh\config" "StrictHostKeyChecking accept-new"
}

$pub_key = Get-Content $pub_key_path
$pub_key_raw = Get-Content "$ssh_path\id_rsa.pub" -Encoding UTF8 -Raw
$bytes_pub_key = [System.Text.Encoding]::UTF8.GetBytes($pub_key_raw)
$encoded_pub_key = [System.Convert]::ToBase64String($bytes_pub_key)

$priv_key = Get-Content "$ssh_path\id_rsa" -Encoding UTF8 -Raw
$bytes_priv_key = [System.Text.Encoding]::UTF8.GetBytes($priv_key)
$encoded_priv_key = [System.Convert]::ToBase64String($bytes_priv_key)

$vm_store_path = $config.vm_store_path
$os_image_path = $config.os_image_path
$imagePath = $config.os_image_path
$github_branch_name = $config.github_branch_name

$hosts=@{}
$all_hosts=@()
$all_hosts+=$config.master_host
$all_hosts+=$config.hosts

if (!$vm_store_path) {
    $vm_store_path="$env:USERPROFILE\binanceB_vm"
}
echo "Generating VMs in $vm_store_path folder"


$eth_adapter=Get-NetAdapter -Name "Ethernet"
$eth_adapter=$eth_adapter.InterfaceDescription

$vm_adapter=Get-NetAdapter -Name "vEthernet (VM)" -ErrorAction SilentlyContinue
if (!$vm_adapter) { 
    echo "generating Virtual switch 'VM' with adapter: $eth_adapter..."
    New-VMSwitch -Name "VM" -NetAdapterName "Ethernet" | Out-Null
}

if (Test-Path -Path $vm_store_path) {
    Remove-Item -LiteralPath $vm_store_path -Recurse
}
New-Item -Path $vm_store_path -ItemType Directory

$master_host_name = ""
$master_host_ip = ""

for ($i=0;$i -lt $all_hosts.Length; $i++) {
    $host_info=$all_hosts[$i].split("@")
    $host_user=$host_info[0]
    $host_ip=$host_info[1]
    $hosts[$host_user]=$host_ip
    echo "Setting up $host_user virtual machine..."

    $encoded_config_content="Cg=="
    if ($all_hosts[$i] -eq $config.master_host) {
        $master_host_name = $host_user
        $master_host_ip = $host_ip
        $main_config_content = Get-Content $config_file_path
        $encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($main_config_content)
        $encoded_config_content = [System.Convert]::ToBase64String($encodedBytes)
    }

    # Set VM Name, Virtual Switch Name, and Installation Media Path.
    $VMName = $host_user
    $virtualSwitchName = 'VM'

    # Set the mac address of the VM
    $decimal_host = 3
    if ($i -gt 9) {
        $decimal_host += 1
    }
    $mac_address = "00155D3801" + $decimal_host + $i

    # ADK Download - https://www.microsoft.com/en-us/download/confirmation.aspx?id=39982
    # You only need to install the deployment tools once
    $oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"

    # Download qemu-img from here: http://www.cloudbase.it/qemu-img-windows/ to be done once
    $qemuImgPath = "E:\Download\qemu-img\qemu-img.exe"

    # Virtual Machine data:
    $GuestOSName = $host_user
    $GuestOSID = $mac_address

$metadata = @"
instance-id: $($GuestOSID)
local-hostname: $($GuestOSName)
"@

$userdata = @"
#cloud-config
package_update: true
package_upgrade: true
users:
 - default
 - name: $($host_user)
   groups: [adm, audio, cdrom, dialout, floppy, video, plugdev, dip, netdev, sudo, users, admin, lxd]
   shell: /bin/bash
   sudo: ['ALL=(ALL) NOPASSWD:ALL']
   ssh-authorized-keys:
   - $($pub_key)
keyboard:
  layout: it
write_files:
 - encoding: b64
   owner: $($host_user):$($host_user)
   path: /home/$($host_user)/.ssh/id_rsa.pub
   content: $($encoded_pub_key)
   permissions: '0600'
   defer: true
 - encoding: b64
   owner: $($host_user):$($host_user)
   path: /home/$($host_user)/.ssh/id_rsa
   content: $($encoded_priv_key)
   permissions: '0600'
   defer: true
 - encoding: b64
   owner: $($host_user):$($host_user)
   content: $($encoded_config_content)
   path: /home/$($host_user)/main_config.json
   permissions: '0777'
   defer: true
 - encoding: b64
   owner: $($host_user):$($host_user)
   content: Cg==
   path: /home/$($host_user)/.ssh/known_hosts
   permissions: '0777'
   defer: true
runcmd:
 - "ssh-keyscan github.com >> /home/$($host_user)/.ssh/known_hosts"
"@

    # set temp path to store temporary files
    $tempPath = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
    # Make temp location
    md -Path $tempPath
    md -Path "$($tempPath)\Bits"
    $metaDataIso = "$($vm_store_path)\$host_user\metadata.iso"

    if (Test-Path -Path "$vm_store_path\$host_user") {
        Remove-Item -LiteralPath "$vm_store_path\$host_user" -Recurse
    }
    New-Item -Path "$vm_store_path\$host_user" -ItemType Directory

    # Output meta and user data to files
    sc "$($tempPath)\Bits\meta-data" ([byte[]][char[]] "$metadata") -Encoding Byte
    sc "$($tempPath)\Bits\user-data" ([byte[]][char[]] "$userdata") -Encoding Byte

    # Convert cloud image to VHDX
    $vhdx = "$vm_store_path\$host_user\test.vhdx"
    & $qemuImgPath convert -f qcow2 $imagePath -O vhdx -o subformat=dynamic $vhdx
    Resize-VHD -Path $vhdx -SizeBytes 50GB

    # Create meta data ISO image
    & $oscdimgPath "$($tempPath)\Bits" $metaDataIso -j2 -lCIDATA

    # Clean up temp directory
    rd -Path $tempPath -Recurse -Force

    $VM_exist = Get-VM -name $VMName -ErrorAction SilentlyContinue | ConvertTo-Json | ConvertFrom-Json
    $VM_exist_name = $VM_exist.Name
    echo $VM_exist_name
    if ($VM_exist_name) { 
        echo "Removing already existing VM $VM_exist_name..."
        Remove-VM -Name $VMName -Force
    }

    echo "Generating VM $host_user with mac address: $mac_address"

    # Create New Virtual Machine
    New-VM -Name $VMName -Generation 2 -VHDPath $vhdx -Path "$vm_store_path\$VMName" -SwitchName $virtualSwitchName
    Set-VMMemory $VMName -DynamicMemoryEnabled $True -MinimumBytes 512MB -StartupBytes 2GB -MaximumBytes 4GB
    Set-VMProcessor $VMName -Count 2
    # Add DVD Drive to Virtual Machine
    # Add-VMScsiController -VMName $VMName
    Add-VMDvdDrive -VMName $VMName -Path $metaDataIso
    Set-VMNetworkAdapter -VMName $VMName -StaticMacAddress $mac_address

    # Disable Secure Boot
    Set-VMFirmware -VMName $VMName -EnableSecureBoot "Off"
    echo "$host_user Virtual Machine installed at $vm_store_path\$host_user"
    # echo "Booting up $host_user virtual machine and preparing for first boot..."
    Start-VM -Name $host_user
}

echo "Starting application installation..."

echo "Waiting for $master_host_name virtual machine to fully boot up..."
Start-Sleep -Seconds 60
if (Test-NetConnection $master_host_name | Where-Object {$_.PingSucceeded -eq "True"}) {
    $work = 1
    $seconds = 30
    while ($work -eq 1) {
        $seconds = $seconds + 5
        Start-Sleep -Seconds $seconds
        $cloud_init_status = ssh $master_host_name@$master_host_ip "cloud-init status"
        if ($cloud_init_status -Match "done") {
            $work = 0
            # ssh-keyscan $master_host_ip | Out-File -Filepath "$HOME/.ssh/known_hosts" -Append
            echo "Cloning branch $github_branch_name..."
            ssh $master_host_name@$master_host_ip "git clone --single-branch --branch $github_branch_name 'git@github.com:rMiccolis/binanceB.git' '/home/$master_host_name/binanceB'"
            ssh $master_host_name@$master_host_ip "chmod u+x /home/$master_host_name/binanceB -R"
            # Start-Process -Verb RunAs cmd.exe -Args '/c', "ssh $master_host_name@$master_host_ip ./binanceB/infrastructure/start.sh -c '/home/$master_host_name/main_config.json' && pause"
            Start-Process -Verb RunAs cmd.exe -Args '/c', "ssh m1@192.168.1.200 && pause"
        } else {
            echo "$master_host_name@$master_host_ip => $cloud_init_status"
        }
    }
}

echo "Done! All hosts are configured."
echo "To start the infrastructure setup run this command on the just opened cmd:"
echo "./binanceB/infrastructure/start.sh -c '/home/$master_host_name/main_config.json'"
Set-Clipboard -Value "./binanceB/infrastructure/start.sh -c '/home/$master_host_name/main_config.json'"
echo "(This command is already copied in the clipboard, you just have to paste it and run it)"
