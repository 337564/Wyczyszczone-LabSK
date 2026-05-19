<#
.Synopsis
    Odpowiednik polecenia "ip" z Linuxa
	Używa Sort-IPv4
.Description
    ip l/a/r/u -4 -6 -Physical -Expand -Resolv
.Parameter -Physical
    Tylko interfejsy fizyczne
.Parameter -4
    IPv4
.Parameter -6
    IPv6
.Parameter -Expand
    Expand IPv6 adress
.Parameter -n
    Numeric : No IP resolving
.Parameter -d
	Debug
.Parameter -l
	format-list (long)
.Parameter command
	l*	: link
	a*	: adress
	r*	: route
	u*	: uptime
	rename*	: Rename ZeroTier Adapters and others known
.Example
    ip l
    ip a
    ip a -4
    ip r
    ip r -6
    ip a -i LAN
.Example
	ip r -list | sort Metric | ft -a			# W kolejności metryki wynikowej
.Link
    Doc/ipv4-sorting.ps1
    Doc/ipv4-sorting.md
.Link
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection
    https://docs.microsoft.com/en-us/powershell/module/nettcpip/get-netroute
.Link
	# Calculated properties:
    https://docs.microsoft.com/en-us/powershell/scripting/samples/selecting-parts-of-objects--select-object-
    https://powershell.one/wmi/root/cimv2/win32_ip4routetable
.Notes
	https://github.com/PowerShell/PowerShell/issues/11334  7.0 : juz OK
.Notes
	Mapowanie nazw interfejsów ZeroTier wymaga modułu ZeroTierController
	$bin\Install\ZeroTierController
.Notes
    ato 2020-2025
	TODO lan dmz
#>
#Requires -Version 7                           	# -TargetName : invalid param.
[CmdletBinding(PositionalBinding=$false)]
param (
	# Tylko flagi - parametr zmienia parsowanie
	[string]$ifAlias ='*',
	[switch]$Expand, # ::
	[switch]$n,
	[switch]$Physical,
	[switch]$Resolv,
	[switch]$All,
	[switch]$List,										# Format-List
	[switch]$Help,
	#[switch]$Debug,									# Nie może wystąpić
	#[switch]$Verbose,									# Nie może wystąpić
	[Parameter(ValueFromRemainingArguments = $true)]    # Musi być
	#[string[]]$Arguments
	[string[]]$Args
	#[switch]$4,										# Dopełnia, nie pobiera i nie ustawia
	#[switch]$6,										# j.w.
)
# Nazwy interfejsów w sieci lokalnej ZET
$ZET_NETS = @{
	'10.146/16' = 'adm'
	'172.29/16' = 'lan'
}
function getHelp {
	Write-Host "użycie: $PROG -opcje arg [-opcje]  # Raporty sieciowe" -f Yellow
	Write-Host 'Opcje:
 -i : interfejs (alias lub index), standardowo wszystkie (*)
 -p : tylko interfejsy fizyczne (physical)
 -4 : IPv4
 -6 : IPv6 (def. IPv4)
 -e : ?expand?
 -n :
 -r : ?resolve?
 -e : expand IPv6
 -f : format
 -l : lista obiektów - bez formatowania
 -v : verbose
 -d : debug
 -h : help'
	Write-Host 'arg:
  l : interfejsy Get-Netadapter    l*
  w : interfejsy WireGuard
  z : interfejsy Zerotier
  a : adressy    Get-NetIPAddress  a*
  n : sąsiedzi   Get-NetNeighbor   n*
  r : trasy      Get-NetRoute      r*
 rd : trasy standardowe (default)
  u : czas pracy interfejsu  (uptime) u*
ren : nadanie nazw znanym interfejsom, np. ZeroTier na podstawie nazw sieci. Wymaga admina'
	<#
Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }
       ip [ -force ] -batch filename
OBJECT := { link | address | addrlabel | route | rule | neigh | ntable | tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |
            netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila | vrf | sr | nexthop | mptcp }
OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |
            -h[uman-readable] | -iec | -j[son] | -p[retty] |
            -f[amily] { inet | inet6 | mpls | bridge | link } |
            -4 | -6 | -I | -D | -M | -B | -0 |
            -l[oops] { maximum-addr-flush-attempts } | -br[ief] |
            -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |
            -rc[vbuf] [size] | -n[etns] name | -N[umeric] | -a[ll] |
            -c[olor]}
#>
}
function Info { if ($Debug) { Write-Host $Args } }
function Expand-Ipv6 ($a, [switch]$All) {
	# Słowo do 4 cyfr i zera do ::
	Info 'i: ' $a -f Green
	$a, $m = $a -split '/'						# Maska
	$a, $i = $a -split '%'						# Interfejs
	foreach ($w in $a -split ':') {
		# Adres
		$n = 4 - $w.Length
		$o += ($n -lt 4) ? ('0' * $n + $w) : ''
		$o += ':'
	}
	if ($All) {
		$n = [int][Math]::Floor((38 - $o.Length) / 4) # 8*5-1-1
		$o = $o -replace '::', (':0000' * $n + ':')
	}
	$o = $o -replace '^:([^:])', '$1'			# [:x -> x  [:: -> ::
	$o = $o -replace '([^:]):$', '$1'			# x:] -> x  ::] -> ::
	Info 'o: ' $o -f Yellow
	return $o
}
function ifName ($ifIndex) {
	if ($ifIndex -eq 1) { return 'LoopBack' }	# Get-NetAdapter nie działa dla 1
	$Name = (Get-NetAdapter -InterfaceIndex $ifIndex -IncludeHidden).Name
	if ($Name -Match 'Bluetooth*') { $Name = 'Bluetooth' }	# Bluetooth Network Connection
	if ($Name -Match 'ZeroTier*') { $Name = Map-ZeroTier $Name }
	return $Name
}
$ETC = "$env:Windir\system32\drivers\etc"
$EthersPath = "$ETC\ethers"			# Define the path to your ethers file
$ethers = @{}
function Get-EtherEntry {
	param (
		[Parameter(Mandatory = $true)]
		[string]$MacAddress
	)
	if ($n) { return $MacAddress }
	#if (-not (Get-Variable -Name 'ethers' -Scope Script -ErrorAction SilentlyContinue)) {
	if ($ethers.Count -eq 0) {
		if (Test-Path -Path $EthersPath) {
			Get-Content -Path $EthersPath | Where-Object { $_ -and $_ -notmatch '^#' } |
				ForEach-Object {
					if ($_ -match '^(\S+)\s+(\S+)\s+') {
						$ethers[$matches[1]] = $matches[2]
					}
				}
		}
	}
	#$ethers									# Debug
	if ($ethers.ContainsKey($MacAddress)) {
		$ethers[$MacAddress]
	} else {
		$MacAddress
	}
}
function Rename-NetAdapterDescription {			# Zmiana InterfaceDescription
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Description
	)
	$Adapter = Get-NetAdapter -Name $Name -ErrorAction SilentlyContinue
	if ($Adapter) {
		$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Enum\ROOT\NET'
		$SubKey = Get-ChildItem $RegPath | Where-Object { $_.GetValue('FriendlyName') -eq $Adapter.InterfaceDescription }
		Set-ItemProperty -Path "$($SubKey.PSPath)" -Name 'FriendlyName' -Value $Description
		#Get-NetAdapter -Name $Name | Select-Object Name, InterfaceDescription, InterfaceAlias
	}
}
function Rename-Adapter {						# Zmiana nazwy i opisu
	Param (
		[string]$Name,
		[string]$NewName,
		[string]$Description
	)
	#write-host "Rename-NetAdapter -Name $Name  -NewName $NewName" -f Magenta
	Rename-NetAdapter -Name "$Name"  -NewName $NewName
	if ($Description) { Rename-NetAdapterDescription -Name $NewName -Description $Description }
}
function Rename-NetAdapters {					# Nazwy interfejsów małymi
	Write-Host 'Renaming NetAdapters ...' -f Yellow
	if (-not (Test-Admin)) { Write-Host 'wymaga prawa Administratora' -f Red ; return }
	# ZeroTier:
	Rename-Adapter -Name *159924d630696ecc*  -NewName wil
	Rename-Adapter -Name *ebe7fbd445c277b3*  -NewName zet -Description 'ZeroTier Virtual Port PW'
	Rename-Adapter -Name *d3ecf5726db603c1*  -NewName adm -Description 'ZeroTier Virtual Port ADM'
	Rename-Adapter -Name *d5e5fb653735e07a*  -NewName js  -Description 'ZeroTier Virtual Port JS'
	Rename-Adapter -Name *edf9356e4e1cc01c*  -NewName zat
	# TODO:
	#get-netAdapter -ifAlias 'ZeroTier One *d5e5fb653735e07a*' | Rename-NetAdapter -NewName js
	#Rename-Adapter -Name *41d49af6c2968e1f*  -NewName sgw
	#Rename-Adapter -Name *83048a0632d2b7a6*  -NewName zetold
	# Hyper-V:
	function  Rename-Adapter2 ($old, $new) {
		# $Config\WSL-ConstantMacAddress.ps1
		Get-NetAdapter -IncludeHidden -InterfaceDescription $old -ErrorAction SilentlyContinue |
			Rename-NetAdapter -NewName $new -ErrorAction SilentlyContinue
		Get-NetAdapter -IncludeHidden -Name $old -ErrorAction SilentlyContinue |
			Rename-NetAdapter -NewName $new -ErrorAction SilentlyContinue
	}
	#Name								InterfaceDescription
	#vEthernet (WSL (Hyper-V firewall))	Hyper-V Virtual Ethernet Adapter
	#vSwitch (WSL (Hyper-V firewall))	Hyper-V Virtual Switch Extension Adapter

	Rename-Adapter2 'Hyper-V Virtual Ethernet Adapter'          'vet'
	Rename-Adapter2 'Hyper-V Virtual Switch Extension Adapter'	'vsw'
	Rename-Adapter2 'vEthernet (WSL (Hyper-V firewall))'		'vfw'	# Cobi 172.29.144.0/20

	Rename-Adapter2 'VirtualBox Host-Only Ethernet Adapter'     'box'	# 2 ?
	Rename-Adapter2 'PANGP Virtual Ethernet Adapter Secure*'	'pcs'	# PCSS
	#Get-NetAdapter | ft InterfaceDescription
	# Tailscale:
	#Rename-NetAdapter -Name Tailscale -NewName ts0	# 'Tailscale'  'Tailscale Tunnel'
	Rename-Adapter2 'Tailscale'									'ts0'
	Rename-Adapter2 'ZeroTier One [d5e5fb653735e07a]'			'zjs'
	# Ethernet  Cisco AnyConnect Secure Mobility Client Virtual Miniport Adapter for Windows x64      70 Up           00-05-9A-3C-7A-00 99.5 Mbps
	Rename-Adapter2 'Cisco AnyConnect*'							'vpn'
	#Get-NetAdapter | ft -a
	<#
    Name                            InterfaceDescription                    ifIndex Status       MacAddress        LinkSpeed
    ----                            --------------------                    ------- ------       ----------        ---------
    Bluetoot_h                      Bluetooth Device (Personal Area Ne...#3      29 Disconnected 00-1B-DC-0F-D3-39    3 Mbps
    ZeroTier One [83048a0632d2b7a6] ZeroTier Virtual Port                        28 Up           A6-15-A5-BD-52-8E  100 Mbps
    ZeroTier One [159924d630696ecc] ZeroTier Virtual Port #2                     69 Up           CE-CC-1E-BF-82-20  100 Mbps
    DMZ__                           Realtek PCIe GbE Family Controller #3        23 Up           38-2C-4A-6C-C0-0A    1 Gbps
    LAN__                           Intel(R) Ethernet Connection I217-LM         15 Up           38-2C-4A-6C-C2-61    1 Gbps
    Tailscale                       Tailscale Tunnel                             67 Up                              100 Gbps
    Wi-Fi 3                         Intel(R) Centrino(R) Advanced-N 6205          9                                    0 bps
    ZeroTier One [d3ecf5726db603c1] ZeroTier Virtual Port #3                      5 Up           C2-A1-C1-E2-26-F1  100 Mbps
    VBox                            VirtualBox Host-Only Ethernet Adap...#2       3 Up           0A-00-27-00-00-03    1 Gbps

    Name       InterfaceDescription                    ifIndex Status       MacAddress        LinkSpeed
    ----       --------------------                    ------- ------       ----------        ---------
    Bluetoot_h Bluetooth Device (Personal Area Ne...#3      29 Disconnected 00-1B-DC-0F-D3-39    3 Mbps
    ZET        ZeroTier Virtual Port                        28 Up           A6-15-A5-BD-52-8E  100 Mbps
    WIL        ZeroTier Virtual Port #2                     69 Up           CE-CC-1E-BF-82-20  100 Mbps
    DMZ__      Realtek PCIe GbE Family Controller #3        23 Up           38-2C-4A-6C-C0-0A    1 Gbps
    LAN__      Intel(R) Ethernet Connection I217-LM         15 Up           38-2C-4A-6C-C2-61    1 Gbps
    Tailscale  Tailscale Tunnel                             67 Up                              100 Gbps
    Wi-Fi 3    Intel(R) Centrino(R) Advanced-N 6205          9                                    0 bps
    ADM_JS     ZeroTier Virtual Port #3                      5 Up           C2-A1-C1-E2-26-F1  100 Mbps
    VBox       VirtualBox Host-Only Ethernet Adap...#2       3 Up           0A-00-27-00-00-03    1 Gbps #>
	Rename-ZETNets
}
function Rename-ZETNets {							# Adresy interfejsów na podstawie adresów sieci LAN ZET:
	function Rename-Adapter ($NetAddr, $Name) {
		$Net, $PrefixLength = $NetAddr -split '/'
		if (-not $Name) {
			$line = $MyInvocation.ScriptLineNumber
			Write-Host "Brak nazwy dla '$NetAddr' (called from line: $line)" -f Magenta
			#$stack = New-Object System.Diagnostics.StackTrace
			#Write-Host "Traceback:`n$stack"
			return
		}
		Get-NetIPAddress -AddressFamily IPv4 |
		Where-Object IPAddress -like "$Net*" |
		Where-Object PrefixLength -eq $PrefixLength |
		Get-NetAdapter | Rename-NetAdapter -NewName $Name
	}
	$ZET_NETS.GetEnumerator() | ForEach-Object {
    	Write-Verbose "$($_.Key) -> $($_.Value)"
		Rename-Adapter -NetAddress $_.Key -Name $_.Value
	}
	#Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -like '172.29.*' | Get-NetAdapter | Rename-NetAdapter -NewName 'lan'
}
function Map-ZeroTier {							# Map network Id to Description $bin/Test/ZeroTier.ps1
	param (
		[Parameter(Mandatory, ValueFromPipeline=$true, HelpMessage='Network Id:')]
		[ValidateNotNullOrEmpty()]
		[string]$Name					 		# Np. ZeroTier One [159924d630696ecc]
	)
	#Get-Module ZeroTierController				# $bin\Install\ZeroTierController
	$Id = $Name -replace '.*\[' -replace ']'
	return 'ZeroTier ' + (Get-ZTNetwork $Id ).Config.Name	# Net Name
}
# TODO dynamicznie:
function Map-Zerotier2 ($NetId) {				# Bez uzycia modułu ZeroTierController
	$Map = {
		ebe7fbd445c277b3  = 'ZET'
		ebe7fbd445c277b3  = 'ZET2'				# Kontroler na s2
		159924d630696ecc  = 'WIL'
		d3ecf5726db603c1  = 'ADM'
		41d49af6c2968e1f  = 'SGW'
		d5e5fb653735e07a  = 'JS'
	}
	$NetName = $Map[$NetId]
Write-Host "'$NetId -> $NetName" -f Red
	retunrn $Map[$NetId]
}
function Resolve ($IP) {
	$Maps = @{									# TODO do DNS-a
		'0.0.0.0'        = 'On-link'
		'192.168.1.1'    = 'gate'
		'172.27.213.22'  = 'ftp'
		'172.27.213.201' = 'var'
		'25.255.255.254' = 'ZeroTier'
	}
	if ($Resolv) {
		$Name = $Maps[$IP]
		if (! $Name) {
			try {
				$Name = (Resolve-DnsName ($IP -replace '/.*', '')).NameHost
			} catch {
				$Name = $IP
			}
		}
	} else {
		$Name = $IP
	}
	return $Name
}
function Format-Mac ($mac) { $mac.ToLower() -replace '-', ':' }
function Get-Links {
	$Name = @{L = 'ifName'		; E = { ifName $_.ifIndex } }
	$Mac = @{L = 'MacAddress'	; E = { Get-EtherEntry (Format-Mac $_.MacAddress) } }
	# "Intel(R) Ethernet Controller (3) I225-LM" -> "Intel(R) Ethernet Controller"
	$Desc = @{L = 'Description'	; E = { $_.InterfaceDescription -replace '((\w+\W+){4}).*', '$1' -replace ' \(','' } } # 3 słowa
	$Speed = @{L = 'Speed'		; E = { '{0,5}' -f $_.Linkspeed.replace('0 bps', '0  bps').replace('bps','') } }	# Align 0
	$MTU = @{L = 'MTU'			; E = { (Get-NetIPInterface -InterfaceIndex $_.ifIndex).NlMTU } }
	Get-NetAdapter -IncludeHidden -Physical:$Physical |
		Where-Object Status -NotMatch 'Not Present' |
		Where-Object Status -NotMatch Disconnected |
		Where-Object InterfaceDescription -NotMatch ISATAP |	# Windows Server 2016:
		# ifName                                        Description                     MacAddress                          Status Speed ifIndex
		#------                                        -----------                     ----------                          ------ ----- -------
		#isatap.{B4EFA547-4968-4D1C-B0CE-CAB9AFB34F9A} Microsoft ISATAP Adapter #3     00:00:00:00:00:00:00:e0:00:00:00:00        100 K      12
		#isatap.{37217669-42DA-4657-A55B-0D995D328250} Microsoft ISATAP Adapter #2     00:00:00:00:00:00:00:e0:00:00:00:00        100 K      17
		#isatap.js.local                               Microsoft ISATAP Adapter        00:00:00:00:00:00:00:e0:00:00:00:00        100 K      14
		#https://learn.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_comparison_operators

		#Local Area Connection* 6 WAN MiniportIP)              Up  0   9
		#Local Area Connection* 7 WAN MiniportIPv6)            Up  0  22
		#Local Area Connection* 8 WAN MiniportNetwork Monitor) Up  0   3
		Where-Object InterfaceDescription -NotMatch 'WAN Miniport' |

		Where-Object ifDesc -NotMatch 'Kernel Debug' |			# WS2016
		Where-Object name -NotMatch 'Teredo' |					# pdc2023
		Sort-Object Status, MacAddress |
		Format-Table -AutoSize $Name, $Desc, $Mac, Status, $Speed, $MTU, ifIndex
}
function Get-Address {
	# https://en.wikipedia.org/wiki/Link-local_address
	# https://en.wikipedia.org/wiki/IPv6#Stateless_address_autoconfiguration_(SLAAC)
	$Name = @{L = 'ifName' ; E = { ifName $_.ifIndex } }
	if ($AF -eq 'IPv4') {
		$Addr = @{L = 'IPAddress' ; E = { $_.IPAddress + ' /' + $_.PrefixLength } }
	} else {
		$Addr = @{L = 'IPAddress' ; E = { (Expand-Ipv6 $_.IPAddress $Expand) + ' /' + $_.PrefixLength } }
	}
	#$IPSort = { [System.Version]([System.Net.IPAddress]$_.IPAddress).ToString() }	# Tylko IPv4
	$IPSort = { ([System.Net.IPAddress]::Parse($_.IPAddress).GetAddressBytes() | ForEach-Object { $_.ToString('x2') }) -join '' }
	Get-NetIPAddress -AddressFamily $AF -InterfaceAlias $ifAlias |
		#Sort-Object PrefixOrigin -Descending |
		#Sort-Object IPAddress |
		#Format-Table -AutoSize $Name,$Addr,*fixOrigin,ifIndex	#IPAddress,Prefixlength,*fixOrigin
		Where-Object { $AF -eq 'IPv6' -or $_.PrefixOrigin -ne 'WellKnown' } |
		Sort-Object $IPsort |
		Select-Object $Name, $Addr, *fixOrigin, ifIndex 	#IPAddress,Prefixlength,*fixOrigin
		#Sort-Object Pr*,IP*  | #($AF -eq 'IPv4' ? 'Pr*' : 'Pr*')
		#Sort-Object ifName, Pr* #|
	#Format-Table -AutoSize
	# TODO? SLAC -> MAC dla IPv6 ?
}
function Get-Neighbor {
	$MacAddress = @{ L = 'MacAddress'; E = { Get-EtherEntry (Format-Mac $_.LinkLayerAddress) } }
	$InterfaceAlias = @{ L = 'Interface' ; E = { Map-ZeroTier $_.InterfaceAlias } }
	$IPAddress = @{ L = 'IPAddress'; E = { Resolve $_.IPAddress } }
	$IPSort = { ([System.Net.IPAddress]::Parse($_.IPAddress).GetAddressBytes() | ForEach-Object { $_.ToString('x2') }) -join '' }
	Get-NetNeighbor -InterfaceAlias $ifAlias -AddressFamily $AF |
		Where-Object State -notin 'Unreachable', 'Permanent' |
		#Sort-Object InterfaceAlias |
		Sort-Object $IPsort |
		Select-Object InterfaceAlias, $IPAddress, $MacAddress, State #, PolicyStore
	#ip n -l | Where-Object state -ne Permanent | Sort-Object $IPSort1 | ft
}
function Get-Routes-Default {
	#Write-Host "Tablica tras z pominięciem rogłoszeń grupowych, powszechnych i sieciowych" -F Yellow -n
	Write-Host 'Tablica tras z pominięciem rogłoszeń' -F Yellow -n
	# Format
	#   F= : FormatString = <string>
	#   w= : Width = <int32>
	#   A= : alignment = value can be Left, Center, or Right
	$Destination = @{L = 'Destination'; E = { $_.DestinationPrefix -replace '0.0.0.0/0', 'Default' } }
	$NextHop = @{ L = 'NextHop'; E = { Resolve $_.NextHop } }
	$Name = @{L = 'ifName' ; E = { ifName $_.ifIndex } }
	$Metric = @{ L = 'Rote+Interf Metric'; E = { $R = $_.RouteMetric; $I = $_.InterfaceMetric ; '{0,4} + {1,2} = {2,5}' -f $R, $I, ($R + $I) } }
	Get-NetRoute -AddressFamily $AF -InterfaceAlias $ifAlias |
		Where-Object NextHop -ne '0.0.0.0' | # On-link
		Where-Object DestinationPrefix -ne '224.0.0.0/4' | # Multicast
		Where-Object DestinationPrefix -ne '255.255.255.255/32' | # Broadcast
		Where-Object DestinationPrefix -NotMatch '.*/32' | # Net Brodcast
		Sort-Object @{E = 'DestinationPrefix'; Descending = $true },
		@{E = { $_.RouteMetric + $_.InterfaceMetric }; Descending = $false } |
		Select-Object $Name, $Destination, $NextHop, $Metric  #,ifIndex
}
function Get-Routes {
	#Get-NetRoute -AddressFamily IPv6 |ft @{L="ifName";E={ifName $_.ifIndex}},DestinationPrefix,NextHop,*Metric -a
	$Name = @{L = 'ifName' ; E = { ifName $_.ifIndex } }
	$NextHop = @{ L = 'NextHop'; E = { Resolve $_.NextHop } }
	$RouteM= @{ L = 'Rote + Int'; E = { '{0,5} + {1,2}' -f $_.RouteMetric, $_.InterfaceMetric }}
	$Metric = @{ L = 'Metric'; E = { '{0,6}' -f ($_.RouteMetric + $_.InterfaceMetric) }}
	Get-NetRoute -AddressFamily $AF -ifAlias $ifAlias |
		#if (! $All) {
		Where-Object DestinationPrefix -ne '127.0.0.0/8' |			# LoopBack
		Where-Object DestinationPrefix -ne '224.0.0.0/4' | 			# Multicast
		Where-Object DestinationPrefix -ne '255.255.255.255/32' |	# Broadcast
		# TODO: lepiej:
		Where-Object -FilterScript { $_.DestinationPrefix -notMatch '.*/32' -or $_.RouteMetric -ne 256 } |
		#   Where { DestinationPrefix -notlike ('224.0.0.0/4', '255.255.255.255/32', '.*/32' ) } |   # Broadcast
		#}
		#Sort-Object ifIndex, DestinationPrefix |
		Select-Object $Name, DestinationPrefix, $NextHop, $RouteM, $Metric |
		Sort-IPv4 Dest*
		#Sort-Object Metric
}
function Get-Routes-CMD {
	netstat -rn
	route print -4
	#Doc:
	Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object -ExpandProperty 'NextHop'
	#25.255.255.254
	#192.168.1.1
	Get-NetRoute |
		Where-Object NextHop -Ne '::' |
		Where-Object NextHop -Ne '0.0.0.0' |
		Where-Object NextHop.SubString(0, 6) -Ne 'fe80::' |
		Get-NetAdapter
	Get-NetRoute | Where-Object ipt { $_.ValidLifetime -Eq ([TimeSpan]::MaxValue) }
}
# https://powershell.one/wmi/root/cimv2/win32_ip4persistedroutetable
function Get-PersistnetRoute {
	Get-CimInstance -ClassName Win32_IP4PersistedRouteTable -Property *
	# Caption Description Destination InstallDate Mask Metric1 Name NextHop Status
}
#  https://docs.microsoft.com/en-us/powershell/module/nettcpip/set-netipinterface
function Set-InterfaceMetric {
	Get-NetAdapter | Where-Object LinkSpeed -EQ '100 Mbps' #| Set-NetIPInterface -InterfaceMetric 21
}
function Get-InterfaceUptime {
	Get-CimInstance Win32_NetworkAdapter | Where-Object NetEnabled -EQ $true |
		Select-Object Name, @{N = 'Uptime'; E = { (Get-Date) - $_.TimeOfLastReset } } |
		Sort-Object Name
	<#
	Name                                  Uptime
	----                                  ------
	Realtek PCIe GBE Family Controller    5.00:32:07.3030865
	Tailscale Tunnel                      5.00:32:07.3027263
	VirtualBox Host-Only Ethernet Adapter 5.00:32:07.3024445
	WireGuard Tunnel                      5.00:32:07.3029336
	ZeroTier Virtual Port                 5.00:32:07.3032384 #>
}

# START

$PROG = Split-Path $MyInvocation.MyCommand.Path -LeafBase

$Debug = $PSBoundParameters['Debug']
$Verbose = $PSBoundParameters['Verbose']

$ifPipeline = $PSCmdlet.MyInvocation.Line -Match '\|'

if ($Verbose) {
	$PSBoundParameters |ft
	Write-Host '$Args' -f Yellow
	$Args | fl *
	Write-Host $Args.Count ':' $Args -f Yellow
	Write-Host "-4 : ${4}" -f R	# TODO
	#return
}
$AF = 'IPv4'
$Expand = $false
#$Sort = $false
$cmd = 'h'
$par = $null
#$Args ; args.ps1 $Args
$Args | ForEach-Object { Info "<$_>" -f Y
	switch -wildcard ($_) {
		'-4' { $AF = 'IPv4' }
		'-6' { $AF = 'IPv6' }
		'-n' { $n = $true }
		'-r' { $r = $true }
		'-e' { $Expand = $trupv6e }
		'-f' { $Format = $true }
		'-s' { $Sort = $true }
		'h*' { $cmd = 'h' }
		'l*' { $cmd = 'l' }				# Link
		'w*' { $cmd = 'w' }				# Wireguard
		'z*' { $cmd = 'z' }				# Zerotier
		'a*' { $cmd = 'a' }				# Address
		'r*' { $cmd = 'r' }				# Route
		'r2' { $cmd = 'r2' }			# route print
		'rd' { $cmd = 'rd' }
		're*'{ $cmd = 'ren' }			# Rename
		'n*' { $cmd = 'n' }
		'u*' { $cmd = 'u' }
		Default { $par = $par, $_ }
	}
}
Info "cmd=$cmd  af=$AF  ifAlias=$ifAlias  Expand=$Expand  par=($($par))"
#Write-Host "Args: $Args" -f Magenta
#args $PSBoundParameters ; return
if ($Help) { getHelp ; return }
switch ($cmd) {
	'l' { $cmd = { Get-Links } }
	'w' { gsudo wg ; return }
	'z' { zerotier-cli listnetworks ; return }	# Get-Zerotier
	'a' { $cmd = { Get-Address } }
	'n' { $cmd = { Get-Neighbor } }
	'r' { $cmd = { Get-Routes } }
	'rd' { $cmd = { Get-Routes-Default } }
	'u' { Get-InterfaceUptime ; return }
	'ren' { Rename-NetAdapters ; return }
	Default { getHelp ; return }
}
if ($List) { &$cmd } else { &$cmd | Format-Table -a }

#&$cmd | if ($List) { $_ } else { $_ | Format-Table -a }
#&$cmd $(if ($List) { } else { | Format-Table -a })
#&$cmd $(if ($List) { | Format-Table -a })
#&$cmd $($List ? { } : { | Format-Table -a })

return
<# k227
Get-NetAdapter -IncludeHidden -InterfaceDescription 'VirtualBox Host-Only Ethernet*' | Rename-NetAdapter -NewName VBOX
Rename-NetAdapter: {Object Exists} An attempt was made to create an object and the object name already existed.
Get-NetAdapter -IncludeHidden -InterfaceDescription 'VirtualBox Host-Only Ethernet*' | Rename-NetAdapter -NewName VBOX2
Rename-NetAdapter: {Object Exists} An attempt was made to create an object and the object name already existed.
Get-NetAdapter -IncludeHidden -InterfaceDescription 'VirtualBox Host-Only Ethernet*' | Rename-NetAdapter -NewName VBOX1
ip l
ifName     Description                     MacAddress        Status   Speed ifIndex
------     -----------                     ----------        ------   ----- -------
Ethernet 3 PANGP Virtual Ethernet Adapter  02:50:41:00:00:01 Disabled   2 G      45
vSwitch    Hyper-V Virtual Switch                            Up        10 G      16
vEthernet  Hyper-V Virtual Ethernet        00:15:5d:bf:7d:79 Up        10 G       8
LAN        ASUS XG-C100C 10G               04:d9:f5:11:67:6f Up        10 G      11
BOX        VirtualBox Host-Only Ethernet   0a:00:27:00:00:2e Up         1 G      46
DMZ        Intel(R) Ethernet Connection    18:66:da:00:7a:5a Up         1 G      14
ZET        ZeroTier Virtual Port #2        b2:d2:42:d1:b8:ee Up       100 M      12
WIL        ZeroTier Virtual Port           ce:cb:e9:a4:ba:31 Up       100 M       6 #>
#EoF