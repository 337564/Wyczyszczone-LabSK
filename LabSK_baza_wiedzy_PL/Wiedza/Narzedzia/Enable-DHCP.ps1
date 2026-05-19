<#
.Synopsis
    Administracja interfejsami sieciowymi
.Notes
    ato 2022
#>

ncpa.cpl    # Edit-Net

Set-NetIPInterface -InterfaceAlias $IfName -Dhcp Enabled

# To add an additional IP address:
New-NetIPAddress –IPAddress $IP –PrefixLength 24 –InterfaceAlias “Ethernet0” –SkipAsSource $True

return
#Eof