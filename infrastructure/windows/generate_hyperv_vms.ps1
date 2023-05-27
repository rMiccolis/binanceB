param(
[string]$config_path,
[string]$imagePath,
[string]$vm_store_path
)
if (!$vm_store_path) {
$vm_store_path="$env:USERPROFILE\binanceB_vm"
echo "Generating VMs in $vm_store_path folder"
}

$config=Get-Content $config_path | ConvertFrom-Json
$eth_adapter=Get-NetAdapter -Name "Ethernet"
$eth_adapter=$eth_adapter.InterfaceDescription

$vm_adapter=Get-NetAdapter -Name "vEthernet (VM)" -ErrorAction SilentlyContinue
if (!$vm_adapter) { 
    echo "generating Virtual switch 'VM' with adapter: $eth_adapter..."
    New-VMSwitch -Name "VM" -NetAdapterName "Ethernet" | Out-Null
}

# if (Test-Path -Path $vm_store_path) {
#     Remove-Item -LiteralPath $vm_store_path -Recurse
# }
# New-Item -Path $vm_store_path -ItemType Directory

$hosts=@{}
$all_hosts=@()
$all_hosts+=$config.master_host
$all_hosts+=$config.hosts
for ($i=0;$i -lt $all_hosts.Length; $i++) {
    $host_info=$all_hosts[$i].split("@")
    $host_user=$host_info[0]
    $host_ip=$host_info[1]
    $hosts[$host_user]=$host_ip

    # Set VM Name, Virtual Switch Name, and Installation Media Path.
    $VMName = $host_user
    $virtualSwitchName = 'VM'
    $GuestOSID = "iid-123456"
    $GuestAdminPassword = "caiosempronio"

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
    $GuestAdminPassword = "ciaociao2"

$metadata = @"
instance-id: $($GuestOSID)
local-hostname: $($GuestOSName)
"@

$userdata = @"
#cloud-config
password: $($GuestAdminPassword)
runcmd:
 - [ useradd, -m, -p, "", ben ]
 - [ chage, -d, 0, ben ]
users:
 - name: master
   passwd: ciaociao123
write_files:
 - encoding: b64
   content: Y2lhb2NpYW8K
   path: /home/master
   permissions: '0555'
 - encoding: b64
   content: Y2lhb2NpYW8K
   path: /home/ben
   permissions: '0555'
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
}
echo "Virtual Machines installed at $vm_store_path"
echo "You have now to install operating system to the newly generated virtual machines!"
echo "Then you have to follow README.md file to setup these virtual machines!"
