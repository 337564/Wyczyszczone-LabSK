<#
.SYnopsis
    Enable ICMP ping response
.Notes 
    ato 2023
#>
#Requires -RunAsAdministrator

New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4
New-NetFirewallRule -DisplayName "Allow ICMPv6-In" -Protocol ICMPv6

Get-NetFirewallRule -DisplayName 'Allow ICMP*' | Format-Table -a

#EoF