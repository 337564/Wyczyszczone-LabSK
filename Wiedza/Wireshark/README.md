# Wireshark, tcpdump i tshark

## Najczęstsze filtry przechwytywania

```bash
tcpdump -i eth0 arp
tcpdump -i eth0 icmp
tcpdump -i eth0 icmp6
tcpdump -i eth0 'udp port 67 or udp port 68'
tcpdump -i eth0 -w ruch.pcapng
```

## Filtry wyświetlania Wiresharka/tshark

```bash
dns || llmnr || mdns || nbns
arp
icmp || icmpv6
bootp          # DHCP w Wiresharku bywa oznaczony jako BOOTP/DHCP
udp.port == 67 || udp.port == 68
```

Zachowano dwie ściągi PacketLife: [`Wireshark_Display_Filters.pdf`](Wireshark_Display_Filters.pdf) i [`tcpdump.pdf`](tcpdump.pdf). Są krótkie i graficzne, dlatego nie przepisywano ich w całości; indeks powyżej zawiera najczęściej używane fragmenty dla laboratoriów.
