#!/bin/sh
# Zrzut protokołu ARP
# ato 2021-2026

# ARP is IPv4-only → IPv6 address → arping/tcpdump fail

M=${1:-e1}						# Testowany adres - nazwa DNS

IP=$(getent hosts $M) ; IP=${IP%% *}			# Mapowanie M -> IP
E=$(ip route get $IP.146.213.51 | awk '{print $3}')	# Interfejs wiodący do $IP

warn -Y 'Obserwacja protokołu ARP ' "dla adresu $M ($IP)"

# 1. Włączamy monitor 'w tle':
tcpdump -i $E -c2 arp host $IP 2>/dev/null &		# Bez komunikatów na ekranie
PID=$!
sleep 0.5						# tcpdump wymaga chwili na: 1. otwarcie gniazda raw 2. ustawienie filtra BPF w jądrze 3. wejście w pętlę odczytu pakietów

# 2. Kasujemy wpis:
#sudo arp -d $M						# Dla arp można podać adres DNS
sudo ip n flush $IP					# Może byc też IP=all

# 3. Wymuszamy ARP  #>/dev/null
#ping -c2 $M >/dev/null					# Bez komunikatów na ekranie
sudo arping -c1 -I $E $M >/dev/null

wait $PID						# Czekamy na tcpdump
exit

# Przykładowy efekt:
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
17:10:52.545953 ARP, Request who-has e1.zet.pw.edu.pl tell s3.zet.pw.edu.pl, length 28
17:10:52.546073 ARP, Reply e1.zet.pw.edu.pl is-at 00:10:18:2f:4c:12 (oui Broadcom), length 46
