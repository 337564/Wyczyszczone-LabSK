#!/bin/sh
# dhcp-zrzut
# Zrzut ruchu protokołu DHCP w systemie Linux.
# Wariant 'console' : sieć obsługiwana przez systemd-network.
# Brak Programu networkmanager który jest w środowisku Gnome.
# ato 2024

# W systemie 'console' siecią administruje systemd-networkd
# https://man.archlinux.org/man/systemd-networkd.8
# https://man.archlinux.org/man/core/systemd/netoworkctl.1.en

# Badamy jego konfigurację dla wybranego interfejsu:
#  systemctrl status systemd-networkd	# Stan serwisu
#  journalctl -u systemd-networkd	# Dziennk serwisu
#  networkctl status $dev		# Stan interfejsu

# Wybieramy wariant używanego klienta DHCP:
# ten wbudowany w systemd-networkd czy też program dhcpcd lub dhclient.
# Optymalne jest użycie DHCP-klienta wbudowanego w systemd-network.
# Inicjalizacja protokołu DHCP sprowadza się do wyłączenia i włączenia interfejsu:
# networkctl down interfejs && networkctl up interfejs

# Gdy chcemy użyć programu dhcpcd lub dhclient musimy najpierw wyłączć obsługę interfejsu
# przez systemd-networkd poleceniem: networkctl delete interfejs

# Dokumentacja:
# https://wiki.archlinux.org/title/Dhcpcd
# https://man.archlinux.org/man/dhcpcd.8
# https://archlinux.org/packages/extra/x86_64/dhcpcd/
# https://roy.marples.name/projects/dhcpcd
# https://man.archlinux.org/man/dhclient.8
# /usr/lib/dhcpcd/dhcpcd-run-hooks

# Doumentacja monitorów ruchu:

# https://man.archlinux.org/man/tshark.1
# https://man.archlinux.org/man/tcpdump.1
# https://gitlab.com/wireshark/wireshark/-/wikis/CaptureFilters

# Zalecane jest używanie monitora bez sudo co wymaga bycia w grupie wireshark
# np. skrypt =wireshark-user

MAC='00:0e:0c:71:70:07'						# Adres serwera DHCP2 (wolniejszy)
MAC='0c:c4:7a:1d:c5:e4'						# Adres serwera DHCP1

Stan_konfiguracji () { # $dev					# Raport konfiguracji
  networkctl list $dev
  networkctl status $dev
  networkctl cat @$dev						# Pliki konfiguracyjne
  ls -l /usr/lib/systemd/network
  ls -l /run/systemd/netif/leases				# DHCP info
  #sc status systemd-networkd-wait-online
}

Start_DHCP () { # $dev						# Wariant 1
  sudo networkctl renew $dev					# Nie generuje ruchu DHCP
  sudo networkctl forcerenew $dev				# j.w.
}

Start_DHCP () { # $dev						# Wariant 2
  sudo systemctl reload systemd-networkd			# OK ale restart psuje DNS! TODO
}

Start_DHCP () { # $dev						# Wariuant 3
  echo "networkctl down + up $dev"
  sudo networkctl down $dev					# Zwolnienie adresu
  sudo networkctl up   $dev					# Alokacja adresu.
  sleep 2							# Czas włączenia karty ~3s
}

Start_DHCP () { # $dev						# Wariuant 4
  echo "ip l set dev $dev down+up"
  sudo ip l set dev $dev down
  sudo ip l set dev $dev up
  sleep 2							# Czas włączenia karty ~3s
}

Start_DHCP () { # $dev						# Wariant 5 Najlepszy?
  sudo networkctl renew $dev					#
}

Do () { warn -Y "$*" ; "$@" ;}					# Polecenie + jego wykonanie

# START

dev=${1:-eth1}							# Nazwa interfejsu klienta
mac=$(ip -br link sho $dev | awk '{print $3}')			# Adres MAC tego interfejsu

filtr_mac="ether src $mac or $MAC"				# Tylko z serwera DHCP i tylko do $dev
filtr="(udp port bootpc or port bootps) and ($filtr_mac)"	# Tylko protokół DHCP

pcap='dhcp.pcap'						# Plik ze zrzutem

#Stan_konfiguracji $dev

Do Start_DHCP $dev						# Wymuszenie pełnego protokołu DHCP

Do tshark   -i $dev -l -w $pcap -f "$filtr" -a packets:5	# Pakiety: 1 + 4
#Do tcpdump -i $dev -l -w $pcap -c "$filtr" -c 5 		#2>/dev/null | ft

Do tshark  -r $pcap -n #-V -N mt --only-protocols dhcp		# m:mac t:port n:names v:vlans

Do tcpdump -r $pcap -n #-e
#Do termshark  dhcp.pcap

Do journalctl -u systemd-networkd -n 9 --no-pager		# Dziennik serwisu

exit
#---------------------------------------------------------------------------------------------------
# networkctl list eth1
IDX LINK  TYPE     OPERATIONAL SETUP
  3 eth1  ether    routable    configured

# labsk/c4/dhcp-zrzut
Capturing on 'eth1'
5
# tshark -i $dev --color -f "udp port bootpc or port bootps and (ether src host $mac or $MAC)"
1 0.000000000       0.0.0.0 → 255.255.255.255 DHCP 333 DHCP Request  - Transaction ID 0x782af8b5
2 4.626601660       0.0.0.0 → 255.255.255.255 DHCP 335 DHCP Discover - Transaction ID 0x79f02f57
3 4.627318806 172.29.146.22 → 172.29.225.10   DHCP 435 DHCP Offer    - Transaction ID 0x79f02f57
4 4.627348037       0.0.0.0 → 255.255.255.255 DHCP 339 DHCP Request  - Transaction ID 0x79f02f57
5 4.627683693 172.29.146.22 → 172.29.225.10   DHCP 435 DHCP ACK      - Transaction ID 0x79f02f57
# tcpdump
02:24:52.645269 IP 0.0.0.0.68       > 255.255.255.255.67: BOOTP/DHCP, Request from e8:40:f2:ec:54:88, length 291
02:24:57.271871 IP 0.0.0.0.68       > 255.255.255.255.67: BOOTP/DHCP, Request from e8:40:f2:ec:54:88, length 293
02:24:57.272588 IP 172.29.146.22.67 > 172.29.225.10.68:   BOOTP/DHCP, Reply, length 393
02:24:57.272617 IP 0.0.0.0.68       > 255.255.255.255.67: BOOTP/DHCP, Request from e8:40:f2:ec:54:88, length 297
02:24:57.272953 IP 172.29.146.22.67 > 172.29.225.10.68:   BOOTP/DHCP, Reply, length 393
# journalctl
maj 22 02:24:49 sa systemd-networkd[7747]: eth1: Link DOWN
maj 22 02:24:49 sa systemd-networkd[7747]: eth1: Lost carrier
maj 22 02:24:49 sa systemd-networkd[7747]: eth1: DHCP lease lost
maj 22 02:24:49 sa systemd-networkd[7747]: eth1: DHCPv6 lease lost
maj 22 02:24:49 sa systemd-networkd[7747]: eth1: Link UP

maj 22 02:24:52 sa systemd-networkd[7747]: eth1: Gained carrier
maj 22 02:24:52 sa systemd-networkd[7747]: eth1: found matching network '/etc/systemd/network/20-ethernet.network', based on potentially unpredictable interface name.
maj 22 02:24:54 sa systemd-networkd[7747]: eth1: Gained IPv6LL
maj 22 02:24:57 sa systemd-networkd[7747]: eth1: DHCPv4 address 172.29.225.10/16, gateway 172.29.146.22 acquired from 172.29.146.22
#EoF
