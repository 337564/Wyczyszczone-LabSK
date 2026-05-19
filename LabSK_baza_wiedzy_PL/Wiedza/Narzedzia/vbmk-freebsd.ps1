<#
.Synopsis
    Generacja maszyny wirtualnej
.Description
    Generacja maszyny wirtualnej FreeBSD w VirtualBox
.Link
    \\ftp\pub\VM\VirtualBox\zetis\PowerShell\install.ps1
.Notes
    file:///C:\Program Files\Oracle\VirtualBox\doc\UserManual.pdf
.Notes
    ato 2020-2021
#>

# Prametry  środowiska:
#$DIR = "\\ftp\pub\FreeBSD\zetis\mfs"           # Katalog z obrazami ISO
#$DIR = "C:\tmp\iso"                             # Katalog z obrazami ISO
$DIR = "\\ftp\pub\FreeBSD\zetis\mfsC:\tmp\iso"  # Katalog z obrazami ISO
$VER = "14.0-CURRENT"                           # Wersja testowa systemu
#$VER = "13.0-RC4"                              # Wersja stabilna systemu

$CPU = $env:PROCESSOR_ARCHITECTURE.ToLower()    # amd64
#$CPU = "amd64"                                 # Maszyna 64 bitowa
#$CPU = "i386"                                  # Maszyna 32 bitowa

$ISO = "$DIR\freebsd-mfs-$VER-$CPU.iso"         # obraz ISO
$PAS = "zetis"

# Parametry maszyny:
#$VM = "FreeBSD-$VER$1"                          # nazwa maszyny
$VM = "FreeBSD-$VER"                          # nazwa maszyny
$RAM = 2048                                     # RAM [MB]
$VRAM = 16                                      # vbox wymaga min 9M vram
# --graphicscontroller none|vboxvga|vmsvga|vboxsvga
$VTYP = 'VMSVGA'                                # Graphics Controller:
# VBoxVGA   : legacy default, bez 3D
# VBoxSVGA  : default
# VMSVGA    : default for Linux, VMware emul.
# none      : bez grafiki
$NCPU = 2                                       # Liczba procesorów
#$NCPU = $env:NUMBER_OF_PROCESSORS / 2           # Liczba procesorów
function Install-vbox {
    //#Requires -RunAsAdministrator
    # Instalacja VirtualBox-a + Pakiet rozszerzeń (ExtensionPack)
    choco install virtualbox  --params "/ExtensionPack /NoDesktopShortcut" -y
    #$env:PATH += ";"
}
function find-host-interface {
    # Interfejs gospodarza podłączony do LAN
    # erg: 225 + 2 wagi równe (brana jest 1)
    #$a = Get-NetRoute -AddressFamily IPv4 -RouteMetric 0 -ErrorAction Ignore | Get-NetAdapter
    $a = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix 0.0.0.0/0 |
    Select-Object -First 1 | Get-NetAdapter
    return $a.ifDesc    # .ifIndex ?
    # 'Intel(R) Dual Band Wireless-AC 8260'
    # 'Intel(R) Ethernet Connection I218-LM'
}
<# var:
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix 0.0.0.0/0 -RouteMetric 0 | ft -a
ifIndex DestinationPrefix NextHop      RouteMetric ifMetric PolicyStore
------- ----------------- -------      ----------- -------- -----------
27      0.0.0.0/0         10.146.146.3           0 25       ActiveStore
21      0.0.0.0/0         194.29.146.1           0 25       ActiveStore
Get-NetAdapter  | ft -a
Name                            InterfaceDescription                    ifIndex Status MacAddress        LinkSpeed
----                            --------------------                    ------- ------ ----------        ---------
ZeroTier One [83048a0632d2b7a6] ZeroTier One Virtual Port                    29 Up     A6-1E-8A-69-1C-E5  100 Mbps
LAN                             QLogic BCM5709C Gigabit Ethernet...#166      27 Up     E4-1F-13-B9-11-B8    1 Gbps
DMZ                             QLogic BCM5709C Gigabit Ethernet...#167      21 Up     E4-1F-13-B9-11-BA    1 Gbps
LAN-1                           Mellanox ConnectX-4 Lx Ethernet Ad...#2      11 Up     AC-1F-6B-8A-67-FC   10 Gbps
LAN-0                           Mellanox ConnectX-4 Lx Ethernet Adapter       9 Up     AC-1F-6B-8A-67-FD   10 Gbps
USB                             IBM USB Remote NDIS Network Device           28 Up     E6-1F-13-AC-11-BB  9.7 Mbps
Npcap Loopback                  Npcap Loopback Adapter                       22 Up     02-00-4C-4F-4F-50  1.2 Gbps
vEthernet (nat)                 Hyper-V Virtual Ethernet Adapter #4          76 Up     00-15-5D-3B-45-85   10 Gbps
vEthernet (SMB_1)               Hyper-V Virtual Ethernet Adapter #2          26 Up     00-15-5D-A8-57-00   10 Gbps
vEthernet (SMB_2)               Hyper-V Virtual Ethernet Adapter #3          14 Up     00-15-5D-A8-57-01   10 Gbps
vEthernet (SETswitch)           Hyper-V Virtual Ethernet Adapter              7 Up     AC-1F-6B-8A-67-FD   10 Gbps
VirtualBox Host-Only Network    VirtualBox Host-Only Ethernet Adapter         5 Up     0A-00-27-00-00-05    1 Gbps
#>
function Add-DHCP-Server {
    [CmdletBinding()]
    Param (
        $NetName = 'VLAN',
        $Address = "10.0.0.1",
        $Mask = "255.255.255.0"
    )
    & $VBM dhcpserver remove --network=$NetName
    & $VBM dhcpserver add --network=$NetName --server-ip=$Address --netmask=$Mask `
        --lower-ip='10.0.0.2'  --upper-ip='10.0.0.100' --enable
}
function Show-DHCP-Server {
    & $VBM list dhcpservers
}
<#
PS C:\> & $VBM list dhcpservers
NetworkName:    HostInterfaceNetworking-VirtualBox Host-Only Ethernet Adapter
Dhcpd IP:       192.168.56.100
LowerIPAddress: 192.168.56.101
UpperIPAddress: 192.168.56.254
NetworkMask:    255.255.255.0
Enabled:        Yes
Global Configuration:
    minLeaseTime:     default
    defaultLeaseTime: default
    maxLeaseTime:     default
    Forced options:   None
    Suppressed opts.: None
        1/legacy: 255.255.255.0
Groups:               None
Individual Configs:   None
#>

# START

#Set-VBM
$VBM = "VBoxManage" # -q"                       # $env:ProgramFiles\Oracle\VirtualBox
$VBM = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage" # -q

& $VBM unregistervm $VM --delete                # Skasowanie maszyny
#$LASTEXITCODE = 1

& $VBM createvm --name $VM --ostype FreeBSD_64 --register
& $VBM modifyvm $VM --memory $RAM --cpus $NCPU --vram 16 --acpi on --hpet on --ioapic on #--nested-hw-virt off

# SATA czy IDE? :
#& $VBM storagectl $VM --add sata --name SATA
#& $VBM storageattach $VM --storagectl SATA --port 0 --type dvddrive --medium $ISO
& $VBM storagectl $VM --add ide --name IDE
& $VBM storageattach $VM --storagectl IDE --port 0 --type dvddrive --medium $ISO --device 0 --tempeject on

# Interfejsy sieciowe:
#$Typ = "82545EM"                               # Typ karty sieciowej: Intel PRO/1000 MT Server
$Typ = "virtio"                                 # Optymalny jeśli gość ma sterownik
$I = 1                                          # Numer interfejsu
$H = find-host-interface                        # Interfejs gospodarza podłączony do LAN
& $VBM modifyvm $VM --nictype$I $Typ --nic$I bridged --bridgeadapter$I $H --nicbootprio$I 2
$I++
$NetName = 'VLAN'                               # dafault: intnet
& $VBM modifyvm $VM --nictype$I $Typ --nic$I intnet
& $VBM modifyvm $VM --intnet$I $NetName

Add-DHCP-Server $NetName                        # dodanie serwera DHCP

& $VBM modifyvm $VM --boot1 dvd                 # z CD (skąd podnosimy system)
#& $VBM modifyvm $VM --boot1 dvd --boot2 none --boot3 none --boot4 none   # Set Boot Order
#& $VBM modifyvm $VM --boot1 net                # z sieci

#& $VBM modifyvm $VM --pae off                  # Disable PAE/NX
#& $VBM modifyvm $VM --usb on --usbehci on      # Set USB Controller
# --nestedpaging on|off
& $VBM modifyvm $VM --nested-hw-virt on         # wirt. zagnieżdżona

# Konsola:
& $VBM modifyvm $VM --graphicscontroller vmsvga
# Konsola zdalna:
#& $VBM modifyvm $VM --vrde on --vrdeport 5901 --vrdeproperty VNCPassword="$PAS"

# Start maszyny:
& $VBM startvm $VM #-type headless
write-host "wystartuj maszynę poleceniem:" -ForegroundColor Green
write-host "$VBM startvm $VM -type headless"
#VBoxHeadless --startvm $VM #--vrde on
return
#EoF

#$cmd= puse resume savestate acpisleepbutton acpipowerbutton reset poweroff
#$cmd = 'acpisleepbutton'
$cmd = 'acpipowerbutton'
& $VBM controlvm $VM $cmd

& $VBM debugvm $VM
& $VBM dhcpserver findlease #--network=netname|--interface=ifname  --mac-address=mac
& $VBM list hostonlyifs
<#
Name:            VirtualBox Host-Only Ethernet Adapter #2
GUID:            1204e642-0d8a-4f0c-ab46-ea024d450357
DHCP:            Disabled
IPAddress:       192.168.56.1
NetworkMask:     255.255.255.0
IPV6Address:     fe80::8131:4b29:5aa4:572b
IPV6NetworkMaskPrefixLength: 64
HardwareAddress: 0a:00:27:00:00:04
MediumType:      Ethernet
Wireless:        No
Status:          Up
VBoxNetworkName: HostInterfaceNetworking-VirtualBox Host-Only Ethernet Adapter #2
#>
