<#
.Synopsis
    Instalacja programów do diagnostyki DNS
.Description
    Programy Unix do diagnostyki DNS : host i dig
.Example
    dig `@172.29.146.202 var.zet +short             # Mapowanie proste
    #172.29.146.201
.Example
    dig `@172.29.146.202 -x 172.29.146.201 +short   # Mapowanie odwrotne
    #var.zet
.Notes
    Resolve-DnsName
.Link
    https://www.isc.org/bind/
    https://chocolatey.org/packages/bind-toolsonly
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator           # Skrypt musi być wykonany przez Administratora systemu

choco install bind-toolsonly -y         # 9.14.2

#refreshenv
#EoF
