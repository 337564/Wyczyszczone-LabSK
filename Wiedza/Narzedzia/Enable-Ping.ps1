<#
.Synopsis
    Włączenie odpowiadania na ping
.Synopsis
    Zapora w Windows 10 standardowo blokuje odpowiedź na ping (ICMP echo)
    Oblokowanie.
.Notes
    ato 2021-2023
#>
function Enable-ICMP-netsh {
    netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol="icmpv4:8,any" dir=in action=allow
    netsh advfirewall firewall add rule name="ICMP Allow incoming V6 echo request" protocol="icmpv6:8,any" dir=in action=allow
}
 
#Set-StrictMode  -Version Latest              # 3.0 
#wershell 
 
#$NET_FW_PROFILE_DOMAIN   = 0 
$NET_FW_PROFILE_STANDARD = 1 
 
$fwMgr = New-Object -com HNetCfg.FwMgr      # Firewall Manager object
 
# Current profile for the local firewall policy. 
$Profile = $fwMgr.LocalPolicy.GetProfileByType($NET_FW_PROFILE_STANDARD) 
 
#$Profile.ICMPSettings                      # Current ICMP settings 
 
$Profile.ICMPSettings.AllowInboundEchoRequest
$Profile.ICMPSettings.AllowInboundEchoRequest = $true 
#$Profile.ICMPSettings.AllowInboundEchoRequest = $false
$Profile.ICMPSettings.AllowInboundEchoRequest
 
#EoF