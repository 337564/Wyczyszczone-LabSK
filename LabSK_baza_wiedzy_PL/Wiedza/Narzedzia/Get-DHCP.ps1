<#
.Synopsis
    Stan DHCP (klient)
.Link
    https://docs.microsoft.com/pl-pl/powershell/scripting/samples/performing-networking-tasks?view=powershell-7.1#performing-dhcp-configuration-tasks
.Notes
    ato 2021
#>

# Lista waszystkiich interfejsCów w tym programowe:
#Get-CimInstance -Class Win32_NetworkAdapter | ft -a

# Stan DHCP na wszystkich interfejsach IP, czasy licencji:
Get-CimInstance -Class Win32_NetworkAdapterConfiguration `
    -Filter "IPEnabled=$true and DHCPEnabled=$true" |
Format-List -Property DHCP,DNS

# EoF
