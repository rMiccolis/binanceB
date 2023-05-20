param(
[string]$config_path
)

$config=Get-Content $config_path | ConvertFrom-Json
$vm_adapter=Get-NetAdapter -Name "Ethernet"
$vm_adapter=$vm_adapter.InterfaceDescription
# echo $vm_adapter
if ($vm_adapter -eq "") { 
    echo "generating Virtual switch 'VM' with adapte: $vm_adapter..."
    New-VMSwitch -Name "VM" -NetAdapterName "Ethernet"
}

$vm_store_path="$env:USERPROFILE\binanceB_vm"
if (Test-Path -Path $vm_store_path) {
    Remove-Item -LiteralPath $vm_store_path -Recurse
    New-Item -Path $vm_store_path -ItemType Directory
} else {
    New-Item -Path $vm_store_path -ItemType Directory
}

$hosts=@{}
$all_hosts=@()
$all_hosts+=$config.master_host
$all_hosts+=$config.hosts
for ($i=0;$i -lt $all_hosts.Length; $i++) {
    $host_info=$all_hosts[$i].split("@")
    $host_user=$host_info[0]
    $host_ip=$host_info[1]
    $hosts[$host_user]=$host_ip
    New-Item -Path "$vm_store_path\\$host_user" -ItemType Directory
    # Set VM Name, Switch Name, and Installation Media Path.
    $VMName = $host_user
    $Switch = 'VM'
    $InstallMedia = 'E:\Desktop\torrent downloads\SO\ubuntu-20.04.6-live-server-amd64.iso'
    $decimal_host = 3
    if ($i -gt 9) {
        $decimal_host += 1
    }
    $mac_address = "00155D3801" + $decimal_host + $i

    echo "Generating VM $host_user with mac address: $mac_address"

    # Create New Virtual Machine
    New-VM -Name $VMName -Generation 2 -NewVHDPath "$vm_store_path\$host_user\$VMName.vhdx" -NewVHDSizeBytes 20GB -Path "$vm_store_path\$VMName" -SwitchName $Switch
    Set-VMMemory $VMName -DynamicMemoryEnabled $True -MinimumBytes 512MB -StartupBytes 2GB -MaximumBytes 4GB
    Set-VMProcessor $VMName -Count 2
    # Add DVD Drive to Virtual Machine
    Add-VMScsiController -VMName $VMName
    Add-VMDvdDrive -VMName $VMName -ControllerNumber 1 -ControllerLocation 0 -Path $InstallMedia
    Set-VMNetworkAdapter -VMName $VMName -StaticMacAddress $mac_address
    # Mount Installation Media
    $DVDDrive = Get-VMDvdDrive -VMName $VMName

    # Configure Virtual Machine to Boot from DVD
    Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive -EnableSecureBoot "Off"
}
echo ""
echo "You have now to install operating system to the newly generated virtual machines!"
echo "Then you have to follow README.md file to setup these virtual machines!"

