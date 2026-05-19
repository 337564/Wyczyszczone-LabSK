<#
.Synopsis
    Odpowiednik arp4 z sortowaniem adresow
.Notes
    ato 2023
#>

Get-NetNeighbor -AddressFamily IPv4 -InterfaceAlias Ethernet0 | sort {$_.IPAddress -as [Version]} | ft -a