<#
.Synopsis 
    Modyfikacja trasy
.Notes 
    ato 2023
#>
    
return

ip r                           
<#
ifName   DestinationPrefix NextHop        RouteMetric InterfaceMetric
------   ----------------- -------        ----------- ---------------
         127.0.0.0/8       0.0.0.0                256              75
Wi-Fi    0.0.0.0/0         192.168.0.252            0              45
Wi-Fi    192.168.0.0/24    0.0.0.0                256              45
Ethernet 0.0.0.0/0         192.168.0.252            0              35
Ethernet 192.168.0.0/24    0.0.0.0                256              35
         0.0.0.0/0         25.255.255.254        9999              35
         10.147.18.0/24    0.0.0.0                256              35
#>
Get-NetRoute -InterfaceAlias Ethernet -AddressFamily IPv4 |ft -a
<#
ifIndex DestinationPrefix  NextHop       RouteMetric ifMetric PolicyStore
------- -----------------  -------       ----------- -------- -----------
12      255.255.255.255/32 0.0.0.0               256 35       ActiveStore
12      224.0.0.0/4        0.0.0.0               256 35       ActiveStore
12      192.168.0.255/32   0.0.0.0               256 35       ActiveStore
12      192.168.0.130/32   0.0.0.0               256 35       ActiveStore
12      192.168.0.0/24     0.0.0.0               256 35       ActiveStore
12      0.0.0.0/0          192.168.0.252           0 35       ActiveStore
#>
sudo New-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex 12 -NextHop "192.168.0.194"
<#
ifIndex DestinationPrefix  NextHop      RouteMetric ifMetric PolicyStore
------- -----------------  -------      ----------- -------- -----------
12      0.0.0.0/0          192.168.0.194        256 35       ActiveStore
12      0.0.0.0/0          192.168.0.194        256          Persistent…
#>
ip r                                                                                                         
<#
ifName   DestinationPrefix NextHop        RouteMetric InterfaceMetric
------   ----------------- -------        ----------- ---------------
         127.0.0.0/8       0.0.0.0                256              75
Wi-Fi    0.0.0.0/0         192.168.0.252            0              45
Wi-Fi    192.168.0.0/24    0.0.0.0                256              45
Ethernet 0.0.0.0/0         192.168.0.194          256              35
Ethernet 0.0.0.0/0         192.168.0.252            0              35
Ethernet 192.168.0.0/24    0.0.0.0                256              35
         0.0.0.0/0         25.255.255.254        9999              35
         10.147.18.0/24    0.0.0.0                256              35
#>
sudo Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex 12 -NextHop "192.168.0.194"
<#
Confirm
Are you sure you want to perform this action?
Performing operation "Remove" on Target "NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceIndex 12 -NextHop 192.168.0.194 -Store Active"
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): n
Confirm
Are you sure you want to perform this action?
Performing operation "Remove" on Target "NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceIndex 12 -NextHop 192.168.0.194 -Store Persistent"
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): n
#>
sudo Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex 12 -NextHop "192.168.0.194"
<#
Confirm
Are you sure you want to perform this action?
Performing operation "Remove" on Target "NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceIndex 12 -NextHop 192.168.0.194 -Store Active"
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
Confirm
12      0.0.0.0/0          192.168.0.194          0 35       ActiveStore
#>
ip r
<#
ifName   DestinationPrefix NextHop        RouteMetric InterfaceMetric
------   ----------------- -------        ----------- ---------------
         127.0.0.0/8       0.0.0.0                256              75
Wi-Fi    0.0.0.0/0         192.168.0.252            0              45
Wi-Fi    192.168.0.0/24    0.0.0.0                256              45
Ethernet 0.0.0.0/0         192.168.0.194            0              35
Ethernet 0.0.0.0/0         192.168.0.252            0              35
Ethernet 192.168.0.0/24    0.0.0.0                256              35
         0.0.0.0/0         25.255.255.254        9999              35
         10.147.18.0/24    0.0.0.0                256              35
#>
ping 192.168.0.252
<#
Pinging 192.168.0.252 with 32 bytes of data:
Reply from 192.168.0.252: bytes=32 time<1ms TTL=64
#>
sudo Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex 12 -NextHop "192.168.0.252"
<#
Confirm
Are you sure you want to perform this action?
Performing operation "Remove" on Target "NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceIndex 12 -NextHop 192.168.0.252 -Store Active"
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
#>
ip r
<#
ifName   DestinationPrefix NextHop        RouteMetric InterfaceMetric
------   ----------------- -------        ----------- ---------------
         127.0.0.0/8       0.0.0.0                256              75
Wi-Fi    0.0.0.0/0         192.168.0.252            0              45
Wi-Fi    192.168.0.0/24    0.0.0.0                256              45
Ethernet 0.0.0.0/0         192.168.0.194            0              35
Ethernet 192.168.0.0/24    0.0.0.0                256              35
         0.0.0.0/0         25.255.255.254        9999              35
         10.147.18.0/24    0.0.0.0                256              35
#>
Test-Connection -TargetName wp.pl -Traceroute -ResolveDestination

Find-NetRoute -RemoteIPAddress (Resolve-DnsName wp.pl | select IP4Address)
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\PersistentRoutes" -Name "<DestinationPrefix>" -Va… 

#EoF