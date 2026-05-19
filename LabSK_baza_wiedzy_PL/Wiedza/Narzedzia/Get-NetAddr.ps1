<#
.Synopsis
	Pobranie parametrów interfejsu sieci
.Description
	Crate hash with net info: name, adapter, mac, ipv4, ipv6
.Example
	$zet = Get-NetAddr zet
	$zet.mac ; $zet.ip4 ; $zet.ip6 ; ($zet.dev).ifIndex ; $zet.dev | ft -a
.Example
	$lan = Get-NetAddr lan
	$zet = Get-NetAddr zet
	$adm = Get-NetAddr adm
.Notes
	ato 2025
#>
function Get-NetAddr ($net) {								# Parametry interfejsu do sieci $net
	$dev = Get-NetAdapter -Name $net -ErrorAction Stop
	return @{
		net = "$net"										# Net name
		dev = $dev											# Net Adapter
		ind = $dev.ifIndex									# Net Adapter Index
		mac = $dev.MacAddress.ToLower() -replace '-',':'	# MAC
		ip4 = ($dev | Get-NetIPAddress -AddressFamily IPv4).IPAddress
		ip6 = ($dev | Get-NetIPAddress -AddressFamily IPv6).IPAddress -replace '%.*$'
	}
}

Get-NetAddr $Args
#EoF