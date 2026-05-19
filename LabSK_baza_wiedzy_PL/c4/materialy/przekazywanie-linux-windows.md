Trasowanie (przekazywanie pakietów pomiędzy interfejsami)
---------------------------------------------------------

We wszystkich systemach trasowanie jest standardowo wyłączone. Dlaczego ?

Trasowanie w systemach Unix konfigurujemy poleceniem sysctl
służącym do konfiguracji parametrów jądra systemu w czasie działania:

  sysctl net.ipv{4,6}.ip_forward

lub precyzyjniej:

  sysctl net.ipv{4,6}.conf[.$arg].$typ | grep forward

  arg : {all,default,interfejs} (interfejs: eth0,eth1,wlan0,lo itp. Np.
  typ : {,bc_,mc}forwarding

mc_ oznacza rozgłoszenia grupowe (multicast)
bc_ oznacza rozgłoszenia powszechne (broadcast) tylko dla ipv4

  # sysctl net.ipv4 | grep forward
  net.ipv4.ip_forward = 0
  net.ipv4.ip_forward_use_pmtu = 0
  net.ipv4.ip_forward_update_priority = 1
  net.ipv4.conf.all.forwarding = 0
  net.ipv4.conf.all.bc_forwarding = 0
  net.ipv4.conf.all.mc_forwarding = 0
  net.ipv4.conf.default.forwarding = 0
  net.ipv4.conf.default.bc_forwarding = 0
  net.ipv4.conf.default.mc_forwarding = 0

  net.ipv4.conf.eth0.forwarding = 0
  net.ipv4.conf.eth0.bc_forwarding = 0
  net.ipv4.conf.eth0.mc_forwarding = 0
  .........

Dla IPv6:

  # sysctl net.ipv6 | grep forward
  net.ipv6.conf.all.forwarding = 0
  net.ipv6.conf.all.mc_forwarding = 0
  net.ipv6.conf.default.forwarding = 0
  net.ipv6.conf.default.mc_forwarding = 0

  net.ipv6.conf.eth0.forwarding = 0
  net.ipv6.conf.eth0.mc_forwarding = 0
  ....

Trasowanie włączamy zmieniając wartość parametru z 0 na 1. Np.

  # net.ipv4.ip_forward = 1
  # net.ipv6.conf.all.forwarding = 1	# dla IPv6

Alternatywna metoda to użycie drzewa /proc/sys/net :

  cat      /proc/sys/net/ipv4/conf/all/forwarding
  echo 1 > /proc/sys/net/ipv4/conf/all/forwarding

---------------------------------------------------------------------

W systemie Windows status przekazywania dla wszystkich interfejsów:

  Get-NetIPInterface -AddressFamily IPv4 | Sort IfIndex | ft ifIndex,ifAlias,ConnectionSt*,Forwarding <#
  ifIndex ifAlias                         ConnectionState Forwarding
  ------- -------                         --------------- ----------
        1 Loopback Pseudo-Interface 1           Connected   Disabled
       16 LAN                                   Connected   Disabled
        4 DMZ                                Disconnected   Disabled
       10 VirtualBox                            Connected   Disabled
       15 ZeroTier One [83048a0632d2b7a6]       Connected   Disabled #>

  Get-NetIPInterface -AddressFamily IPv6 | Sort IfIndex | ft ifIndex,ifAlias,ConnectionSt*,Forwarding <#
  ifIndex ifAlias                         ConnectionState Forwarding
  ------- -------                         --------------- ----------
        1 Loopback Pseudo-Interface 1           Connected   Disabled
       16 LAN                                   Connected   Disabled
       10 VirtualBox                            Connected   Disabled
       15 ZeroTier One [83048a0632d2b7a6]       Connected   Disabled #>

Włączenie przekazywania dla jednego interfejsu $DEV:

  Set-NetIPInterface -ifAlias $DEV -Forwarding Enabled

Włączenie przekazywania dla wszystkich interfejsów:

  Set-NetIPInterface -Forwarding Enabled

Włączony musi być też serwis "Trasowanie i Zdalny Dostęp" który jest standardowo wyłączony:

  Get-Service RemoteAccess <#
  Status   Name               DisplayName
  Stopped  RemoteAccess       Routing i dostęp zdalny #>

  Start-Service RemoteAccess
  Set-Service RemoteAccess -StartupType Automatic

Funkcje obsługi tabilcy tras:

  Get-Command -Name *route* -Module NetTCPIP |ft Name,C*type -a <#
  Name            CommandType
  ----            -----------
  Get-NetRoute       Function
  New-NetRoute       Function
  Set-NetRoute       Function
  Find-NetRoute      Function
  Remove-NetRoute    Function #>

#EoF
