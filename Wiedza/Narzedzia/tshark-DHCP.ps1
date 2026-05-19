<#
.Synopsis
	Zrzut ruchu dhcp
.Description
	The simple filter dhcp shows all DHCP packets.
	If you look at the fields, you'll find dhcp.option.dhcp. This field represents the "DHCP Message Type" (option 53).
    A DHCP Discover message has this type set to 1.
    A DHCP Offer message has this type set to 2.
    A DHCP Request message has this type set to 3.
    A DHCP ACK message has this type set to 5.
	So, to filter for only DHCP Discover messages, your "constructed" filter would be:
		-Y "dhcp.option.dhcp == 1"
	To filter for DHCP packets coming from a specific client MAC address:
		-Y "dhcp && dhcp.chaddr == 00:11:22:33:44:55"
.Example
	shark -r dhcp..pcapng -Y "dhcp" -c 1 -V
	# OR for a more focused view on just the DHCP protocol:
	tshark -r dhcp.pcapng -Y "dhcp" -c 1 -O dhcp
.Link
.Notes
	ato 2025
#>