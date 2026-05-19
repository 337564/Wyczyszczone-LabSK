<#
.Synopsis
	Zrzut ruch protokołów mapowania nazw: DNS, mDNS, LLMNR, NBNS
.Description
.Parameter Netadapter
	Interfejs sieciowy , def. zet
	-V : pełny zrzut
	-G protocols : lista protokołów
	Czas:
	-da : 01:32:23,833824
	-dd : delta
.Example
	tskar-NR
	Resolve-DnsName
.Link
	https://learn.microsoft.com/troubleshoot/windows-client/networking/troubleshoot-dns-client-resolution-issues
.Notes
	Rekwizyt: Get-NetAddr
	ato 2025
#>
$MAN = 'https://www.wireshark.org/docs/man-pages/tshark.html'

# START

#New-ALias tshark "$env:programFiles\Wireshark\tshark.exe"

switch ($args[0]) {
	'-h' { write-Host $MAN -f Yellow ; return }
	#Default {}
}

# Protokoły:
$PROTO = 'dhcp'
$PROTO = '(dns || llmnr || mdns || nbns)'

# Adresy specjalne:
# Rozgłoszenie powszechne:
$IP4B = '255.255.255.255' ; $FF = $MACB = 'ff:ff:ff:ff:ff:ff' # MAC broadcast
# Link-Local Multicast Name Resolution (LLMNR) address:
$LLMNR4 = '224.0.0.252' ; $LLMNRM = '01:00:5E:00:00:fc' # LLMNR destination IPv4
$LLMNR6 = 'ff02::1:3'									# LLMNR destination IPv6

# Filters based on the Layer 3 (Network Layer) IP addresses
$IP = '172.27.27.229'
$IP_S = "ip.src == $IP"								# Source IP
$IP_D = "ip.des == 224.0.0.252"						# Destination IP
$IP_A = "ip.addr == 224.0.0.252"					# Source OR Destination IP

# Filters based on the Layer 2 (Data Link Layer) MAC addresses
$MAC_S = "eth.src == 00:11:22:33:44:55:66"			# Source MAC
$MAC_D = "eth.des == 224.0.0.252"					# Destination MAC
$MAC_A = "eth.addr == 224.0.0.252"					# Source OR Destination MAC

# Adresy interfejsów sieci:
$lan = Get-NetAddr lan #; $lan.mac ; $lan.ip4 ; $lan.ip6 ; ($lan.dev).ifIndex ; $lan.dev | ft -a
$zet = Get-NetAddr zet
$adm = Get-NetAddr adm

$f = ''												# -f Filter
$Y = $PROTO											# -Y Filter

# Porty:
#udp.port == 53
#udp.srcport ==
#udp.desport ==
#tcp.port == https
#-Y 'tcp.port == domain || udp.port == domain'
#-f 'tcp dst port 22'
#-f 'udp src port 5353'
#-f 'udp src port domain'

<# Konstrukcja filtrów:
Display Filters (-Y):
	More flexible, uses Wireshark's rich dissection fields,
	applied after packets are captured and dissected.
	Good for detailed analysis.
Capture Filters (-f):
	More efficient, filters at the kernel level (or early in the capture process),
	applied before full dissection. Good for reducing the volume of captured data.
.Notes
	Always enclose your filter string in quotes if it contains spaces or special characters.
#>

#$Y += "$IP_S" ? "&& $IP_S" : ''
#$Y += "$IP_D" ? "&& $IP_D" : ''
#$Y += "$IP_A" ? "&& $IP_A" : ''

#$Y += "$MAC_S" ? "&& $MAC_S" : ''
#$Y += "$MAC_D" ? "&& $MAC_D" : ''
#$Y += "$MAC_A" ? "&& $MAC_A" : ''

$Y_NBNS = 'nbns && (ip.addr = $MYIP || ip.addr == $IP2)'
$Y_DHCP = "dhcp && (eth.addr = $zet.mac || eth.des == $FF)"

# Przykłady:
#tshark -i <interface> -f "ether src 00:1A:2B:3C:4D:5E" -Y "(dns || llmnr || mdns || nbns)"
#tshark --color -Y '(dns || llmnr || mdns || nbns) && ip.src == 172.27.27.229' -i zet -ta
#tshark -i <interface> -Y "tcp.dstport == https || udp.dstport == mdns"

$cmd = "tshark --color -Y '$Y' $Args" # "tshark --color -Y '(dns || llmnr || mdns || nbns)' $Args"
Write-Host "$cmd" -f Yellow
Invoke-Expression $cmd
return
#EoF