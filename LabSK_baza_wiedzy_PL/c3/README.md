# c3 — IPv6, ARP, ICMP, DHCP i analiza ruchu

## Cel ćwiczenia

Ćwiczenie łączy administrację adresami IP z obserwacją rzeczywistego ruchu siećiowego. Najważniejsze jest nie tylko uruchomić polecenia, ale umieć wyjaśnić, jaki pakiet pojawił się w sieći i dlaczego.

Zakres:

- analiza konfiguracji IPv6,
- dodawanie i usuwanie adresów IPv4 oraz IPv6,
- działanie DHCP dla IPv4,
- ARP i ICMP,
- zrzuty ruchu w `tcpdump`, `tshark`, Wiresharku albo termsharku.

## ARP

ARP mapuje adres IPv4 na adres MAC w lokalnej sieći L2. Host, który zna docelowy adres IPv4, ale nie zna MAC, wysyła zapytanie broadcast: „kto ma ten adres IP?”. Właściciel adresu odpowiada swoim MAC.

Przydatne polecenia:

```bash
ip neigh
arp -a              # starsze systemy i Windows
sudo ip neigh flush 10.146.225.1
sudo arping -c1 -I eth0 10.146.225.1
```

Monitorowanie ARP:

```bash
sudo tcpdump -i eth0 arp
sudo tshark -i eth0 -f arp
```

ARP jest protokołem stanowym w sensie utrzymywania pamięci podręcznej sąsiadów, ale nie ma bezpiecznego uwierzytelniania odpowiedzi. Z tego powodu możliwy jest ARP spoofing.

## ICMP

ICMP służy do komunikatów diagnostycznych i sterujących w IP. Najbardziej znany przykład to `ping`, który używa ICMP Echo Request i Echo Reply.

```bash
ping -c4 10.146.225.1
traceroute 8.8.8.8
```

Monitorowanie ICMP:

```bash
sudo tcpdump -i eth0 icmp
sudo tcpdump -i eth0 icmp6
```

## DHCP dla IPv4

DHCP przydziela klientowi przede wszystkim:

1. adres IPv4 i maskę/prefiks,
2. bramę domyślną,
3. serwery DNS,
4. dodatkowe opcje, np. czas dzierżawy, domenę, serwer logów, nazwę hosta.

Klasyczny przebieg to DORA:

1. **Discover** — klient szuka serwera,
2. **Offer** — serwer proponuje konfigurację,
3. **Request** — klient wybiera ofertę,
4. **Ack** — serwer potwierdza dzierżawę.

Porty DHCP IPv4:

- klient: UDP 68,
- serwer: UDP 67.

Monitorowanie DHCP:

```bash
sudo tcpdump -i eth0 -n 'udp port 67 or udp port 68'
sudo tshark -i eth0 -f 'udp port 67 or udp port 68'
```

W systemach z `systemd-networkd` odnowienie konfiguracji często sprowadza się do opuszczenia i podniesienia interfejsu:

```bash
sudo networkctl down eth0
sudo networkctl up eth0
```

Jeśli używasz `dhcpcd` jednorazowo do testu, stosuj tryb testowy/jednorazowy, aby nie zostawić demona w tle:

```bash
sudo dhcpcd -T1 eth0
```

## IPv6 w praktyce

Adresy IPv6 link-local (`fe80::/10`) pojawiają się automatycznie i są używane m.in. przez Neighbor Discovery. Dla poleceń wykonywanych poza systemem rozwiązywania nazw trzeba czasem podać interfejs:

```bash
ping -6 fe80::1%eth0
```

Do analizy IPv6 używaj:

```bash
ip -6 addr
ip -6 route
ip -6 neigh
```

## Jak robić zrzuty ruchu

Najpierw ustaw filtr możliwie blisko problemu, a dopiero potem wymuś ruch:

```bash
sudo tcpdump -i eth0 -w dhcp.pcapng 'udp port 67 or udp port 68'
```

Zapis do pliku ma przewagę nad samym wypisaniem na ekran: można wrócić do pakietów, otworzyć je w Wiresharku, zastosować filtry wyświetlania i dołączyć dowód do sprawozdania.

## Pliki w tym katalogu

- `skrypty/arp-zrzut.sh` — przykład wymuszenia i obserwacji ARP.
- `skrypty/dhcp-zrzut.sh` — przykład diagnostyki DHCP na Linuksie.
- `pcap/` — zachowane przykładowe zrzuty ruchu DHCP/ICMP.
- `zadania/` — zadania i wejściówki.
- `linki.md` — linki do dokumentacji DHCP, Wiresharka i `tshark`.
