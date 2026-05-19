<#
.Synopsis
	Automatyczne dodanie przyroska 'zet' dla interfejsu sieci ZeroTier ZET
.Link
	https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclient
.Notes
	ato 2023
#>
$ZET = '83048a0632d2b7a6'	# Identyfikator sieci

#Get-DnsClient | ft -a

Get-DnsClient | Where-Object -Property InterfaceAlias -Match $ZET |
	Set-DnsClient -ConnectionSpecificSuffix 'zet'
return
#EoF
<#
~ > Get-DnsClient
InterfaceAlias               Interface ConnectionSpecificSuffix ConnectionSpecificSuffix RegisterThisConn UseSuffixWhen
                             Index                              SearchList               ectionsAddress   Registering
--------------               --------- ------------------------ ------------------------ ---------------- -------------
DMZ                                  4                          {}                       False            False
LAN                                 17 home                     {home, home}             True             False
VirtualBox                          11                          {}                       True             False
ZeroTier One [83048a0632d2b…        16                          {}                       True             False
ZeroTier One [d3ecf5726db60…        60                          {}                       True             False
Loopback Pseudo-Interface 1          1                          {}                       True             False
#>
