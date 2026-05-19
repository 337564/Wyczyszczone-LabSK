<#
.Synopsis
    Odnawia adres DHCP na interfejsie - odpowiednik ipconfig /renew
.Description
.Link
    https://docs.microsoft.com/en-us/powershell/scripting/samples/performing-networking-tasks
    https://lizardsystems.com/articles/managing-dhcp-powershell/
    https://docs.microsoft.com/en-us/powershell/module/nettcpip/set-netipinterface
.Notes
    ato 2020
#>
function Set-InterfaceMetric {
    l.IPConnectionMetric = 25

}
function Renew-DHCP-Remote ($Computer,$Adaper) {
    $description = "Linksys WirelessG USB"
    $adapter = GetWmiObject Win32_NetworkAdapterConfiguration –Computer $Computer |
        WhereObject { $_.Description –match $description }
    $adapter.RenewDHCPLease()
}
function Get-DHCPInfo {
    $FIlter = "DHCPEnabled=$true and IPEnabled=$true"
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter $Filter | Format-Table -Property DHCP*
}
function Enable-DHCP {
    $FIlter = "DHCPEnabled=$true and IPEnabled=$true"
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter $Filter |
        ForEach-Object -Process {$_.EnableDHCP()}
}
function Disable-DHCP {
    Set-NetIPInterface -InterfaceIndex 12 -Dhcp Disabled
}
function Enable-DHCP {
    Set-NetIPInterface -InterfaceIndex 12 -Dhcp Enabled
}

# Metrics:
Get-NetAdapter | Where-Object -FilterScript {$_.LinkSpeed -Eq "100 Mbps"} |
    Set-NetIPInterface -InterfaceMetric 21

function DHCP-Renew0 {
    $Filter = "IPEnabled=$true and DHCPEnabled=$true and DHCPServer='192.168.1.254'"
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter $Filter |
        #Where-Object {$_.DHCPServer -contains '192.168.1.254'} |
        #ForEach-Object -Process {$_.ReleaseDHCPLease()}
        ForEach-Object -Process {$_.RenewDHCPLease()}
}
function DHCP-Renew {
    $FIlter = "DHCPEnabled=$true and IPEnabled=$true and DHCPServer='255.255.255.255'" # and Index=4
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter $Filter | ForEach-Object {
        #Write-Host "Flushing IP addresses" -ForegroundColor Yellow
        #$_.ReleaseDHCPLease() | out-Null
        Write-Host "Renewing IP Addresses" -ForegroundColor Green
        $_.RenewDHCPLease() #| out-Null
        Write-Host "The New Ip Address is "$_.IPAddress" with Subnet "$_.IPSubnet"" -ForegroundColor Yellow
    }
}
function xx {
    $FIlter = "DHCPEnabled=$true and IPEnabled=$true and DHCPServer='255.255.255.255'"
    Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter $Filter -ComputerName . |
        #ForEach-Object -Process {$_.InvokeMethod("ReleaseDHCPLease",$null)
        ForEach-Object -Process {$_.InvokeMethod("RenewDHCPLease",$null)
    }
}
Get-DHCPInfo
#DHCP-Renew
return

Get-NetAdapter -InterfaceAlias LAN | fl
<#
Name                       : LAN
InterfaceDescription       : Realtek PCIe GBE Family Controller
InterfaceIndex             : 19
MacAddress                 : 38-2C-4A-6C-BF-65
MediaType                  : 802.3
PhysicalMediaType          : 802.3
InterfaceOperationalStatus : Up
AdminStatus                : Up
LinkSpeed(Gbps)            : 1
MediaConnectionState       : Connected
ConnectorPresent           : True
DriverInformation          : Driver Date 2015-04-06 Version 9.1.406.2015 NDIS 6.40
#>

Get-NetIPAddress -InterfaceAlias LAN -AddressFamily IPv4 -IPAddress 169*
<#
IPAddress         : 169.254.71.2
InterfaceIndex    : 19
InterfaceAlias    : LAN
AddressFamily     : IPv4
Type              : Unicast
PrefixLength      : 16
PrefixOrigin      : WellKnown
SuffixOrigin      : Link
AddressState      : Preferred
ValidLifetime     : Infinite ([TimeSpan]::MaxValue)
PreferredLifetime : Infinite ([TimeSpan]::MaxValue)
SkipAsSource      : False
PolicyStore       : ActiveStore
#>

Get-NetIPConfiguration -InterfaceAlias LA
<#
ComputerName                          : KUC
InterfaceAlias                        : LAN
InterfaceIndex                        : 19
InterfaceDescription                  : Realtek PCIe GBE Family C
NetCompartment.CompartmentId          : 1
NetCompartment.CompartmentDescription : Default Compartment
NetAdapter.LinkLayerAddress           : 38-2C-4A-6C-BF-65
NetAdapter.Status                     : Up
NetProfile.Name                       : Unidentified network
NetProfile.NetworkCategory            : Public
NetProfile.IPv6Connectivity           : NoTraffic
NetProfile.IPv4Connectivity           : NoTraffic
IPv6LinkLocalAddress                  : fe80::a909:64f8:ac6c:4702
IPv4Address                           : 169.254.71.2
IPv6DefaultGateway                    :
IPv4DefaultGateway                    :
NetIPv6Interface.NlMTU                : 1500
NetIPv4Interface.NlMTU                : 1500
NetIPv6Interface.DHCP                 : Enabled
NetIPv4Interface.DHCP                 : Enabled
DNSServer                             : fec0:0:0:ffff::1
                                        fec0:0:0:ffff::2
                                        fec0:0:0:ffff::3
#>

Get-NetIPConfiguration
<#
InterfaceAlias       : VirtualBox
InterfaceIndex       : 11
InterfaceDescription : VirtualBox Host-Only Ethernet Adapter
IPv4Address          : 192.168.56.1
IPv6DefaultGateway   :
IPv4DefaultGateway   :
DNSServer            : fec0:0:0:ffff::1
                       fec0:0:0:ffff::2
                       fec0:0:0:ffff::3

InterfaceAlias       : LAN
InterfaceIndex       : 19
InterfaceDescription : Realtek PCIe GBE Family Controller
NetProfile.Name      : Unidentified network
IPv4Address          : 169.254.71.2
IPv6DefaultGateway   :
IPv4DefaultGateway   :
DNSServer            : fec0:0:0:ffff::1
                       fec0:0:0:ffff::2
                       fec0:0:0:ffff::3

InterfaceAlias       : Npcap Loopback Adapter
InterfaceIndex       : 21
InterfaceDescription : Npcap Loopback Adapter
IPv4Address          : 169.254.16.122
IPv6DefaultGateway   :
IPv4DefaultGateway   :
DNSServer            : fec0:0:0:ffff::1
                       fec0:0:0:ffff::2
                       fec0:0:0:ffff::3

InterfaceAlias       : ZeroTier One [83048a0632d2b7a6]
InterfaceIndex       : 8
InterfaceDescription : ZeroTier One Virtual Port
NetProfile.Name      : Network 6
IPv4Address          : 172.29.146.5
IPv6DefaultGateway   :
IPv4DefaultGateway   : 25.255.255.254
DNSServer            : fec0:0:0:ffff::1
                       fec0:0:0:ffff::2
                       fec0:0:0:ffff::3

InterfaceAlias       : WiFi
InterfaceIndex       : 13
InterfaceDescription : RangeMax Dual Band Wireless-N USB Adapter
NetProfile.Name      : wilk 7
IPv4Address          : 192.168.1.29
IPv6DefaultGateway   :
IPv4DefaultGateway   : 192.168.1.1
DNSServer            : 192.168.1.1

InterfaceAlias       : DMZ
InterfaceIndex       : 4
InterfaceDescription : Intel(R) Ethernet Connection I217-LM
NetAdapter.Status    : Disconnected
#>
#EoF