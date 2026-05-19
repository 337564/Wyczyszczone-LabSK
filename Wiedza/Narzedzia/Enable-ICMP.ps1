<#
.Synopsis
    Włączenie odpowiadania na ping
.Synopsis
    Zapora w Windows 10 standardowo blokuje odpowiedź na ping (ICMP echo)
    Oblokowanie.
.Parameter -e
	Enable ICMP ping response
.Parameter -d
	Disable ICMP ping response
.Notes
    ato 2021
#>
##Requires -RunAsAdministrator
[CmdletBinding()]
param (
	[Parameter()]
	[switch]$Enable,
	[switch]$Disable
)
Set-StrictMode -Version Latest              			# 3.0
function Enable-ICMP-netsh {							# cmd.exe:
	netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol="icmpv4:8,any" dir=in action=allow
	netsh advfirewall firewall add rule name="ICMP Allow incoming V6 echo request" protocol="icmpv6:8,any" dir=in action=allow
}
function Enable-ICMP-ping {
	New-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -Protocol ICMPv4
	New-NetFirewallRule -DisplayName 'Allow ICMPv6-In' -Protocol ICMPv6
}
function Disable-ICMP-ping {
	Disable-NetFirewallRule -DisplayName 'Allow ICMPv4-In'
	Disable-NetFirewallRule -DisplayName 'Allow ICMPv6-In'
	#Remove-NetFirewallRule -DisplayName 'Allow ICMPv6-In'
}
function Enable-ICMP-Manager {
	#$NET_FW_PROFILE_DOMAIN  = 0
	$NET_FW_PROFILE_STANDARD = 1

	$fwMgr = New-Object -com HNetCfg.FwMgr      		# Firewall Manager object
	# Current profile for the local firewall policy.
	$Profile = $fwMgr.LocalPolicy.GetProfileByType($NET_FW_PROFILE_STANDARD)
	#$Profile.ICMPSettings                      		# Current ICMP settings
	$Profile.ICMPSettings.AllowInboundEchoRequest
	$Profile.ICMPSettings.AllowInboundEchoRequest = $true
	#$Profile.ICMPSettings.AllowInboundEchoRequest = $false
	$Profile.ICMPSettings.AllowInboundEchoRequest
}

# START

if ($Enable) {
	Test-Admin
	Enable-ICMP-ping
} elseif ($Disable) {
	Test-Admin
	Disable-ICMP-ping
}

Get-NetFirewallRule -DisplayName 'Allow ICMP*' | Format-Table Display*,Profile,Enabled,Action

return

#EoF
<# Przykład:
# ip a
ifName                          IPAddress          PrefixOrigin SuffixOrigin ifIndex
------                          ---------          ------------ ------------ -------
                                127.0.0.1/8           WellKnown    WellKnown       1
DMZ                             169.254.143.165/16    WellKnown         Link       5
VirtualBox                      169.254.15.196/16     WellKnown         Link      11
WinTun                          169.254.19.230/16     WellKnown         Link      20
Tailscale                       169.254.83.107/16     WellKnown         Link      48
ZeroTier One [83048a0632d2b7a6] 172.29.66.5/16           Manual       Manual      14
wg0                             172.30.66.5/16           Manual       Manual      50
LAN                             192.168.1.5/24             Dhcp         Dhcp      17

# ping 172.30.66.5
Pinging 172.30.66.5 with 32 bytes of data:
Reply from 172.30.66.5: bytes=32 time<1ms TTL=128
Reply from 172.30.66.5: bytes=32 time<1ms TTL=128
Reply from 172.30.66.5: bytes=32 time<1ms TTL=128
Ping statistics for 172.30.66.5:
    Packets: Sent = 3, Received = 3, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
Control-C
C:\ # $fwMgr = New-Object -com HNetCfg.FwMgr
C:\ # $NET_FW_PROFILE_STANDARD = 1
C:\ # $Profile = $fwMgr.LocalPolicy.GetProfileByType($NET_FW_PROFILE_STANDARD)
C:\ # $Profile.ICMPSettings
AllowOutboundDestinationUnreachable : False
AllowRedirect                       : False
AllowInboundEchoRequest             : False
AllowOutboundTimeExceeded           : False
AllowOutboundParameterProblem       : False
AllowOutboundSourceQuench           : False
AllowInboundRouterRequest           : False
AllowInboundTimestampRequest        : False
AllowInboundMaskRequest             : False
AllowOutboundPacketTooBig           : False
C:\ # $Profile.ICMPSettings.AllowInboundEchoRequest = $true
C:\ # $Profile.ICMPSettings
AllowOutboundDestinationUnreachable : False
AllowRedirect                       : False
AllowInboundEchoRequest             : True
AllowOutboundTimeExceeded           : False
AllowOutboundParameterProblem       : False
AllowOutboundSourceQuench           : False
AllowInboundRouterRequest           : False
AllowInboundTimestampRequest        : False
AllowInboundMaskRequest             : False
AllowOutboundPacketTooBig           : False
#>
