<#
.Synopsis
    Edycja mapowań statycznych DNS
.Description
    Skrypt startuje edytor VSC z plikiem hosts
.Link
    https://pl.wikipedia.org/wiki/Hosts
.Notes
    ato 2021
#>
##Requires -RunAsAdministrator  # zbędne - VSC radzi sobie

$HOSTS = "$env:windir\System32\drivers\etc\hosts"

code $HOSTS

#EoF
