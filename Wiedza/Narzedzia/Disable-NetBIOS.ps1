<#
.Synopsis
	Disable NetBIOS over TCP/IP for all NICs, without need for disable/enable or reboot:
.Description
	NetBIOS is a relic of legacy network technology
.Example
	nbstat
.Notes
	ato 2025
#>
#Requires -RunAsAdministrator
wmic nicconfig where "IPEnabled=true" call SetTcpipNetbios 2
# Sprawdzenie:
ipconfig /all | Select-String -r 'NetBIOS'
return
#EoF