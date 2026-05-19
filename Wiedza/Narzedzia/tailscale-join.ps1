<#
.Synopsis
    Instalacja tailscale i podpięcie do sieci
.Description
   Skrypt wykonuje nastepujące kroki:
     1. Instalacja tailscale
     2. Podpięcie do sieci @pw.edu.pl lub ZET (LabSK)
     3. Eksport przydzielonego adresu IPv4 do volta
.Link
    https://tailscale.com/
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

$KeyFile = "$HOME/tailscale.klucz"    	    # Plik na przechowanie klucza do sieci ZET

#choco search tailscale                     # Jakie wersje są dostepne ?
choco install tailscale -y                  # Instalacja

refreshenv                                  # Aktualizacja $env:PATH

tailscale version			    # 1.6.0

tailscale status

# Podpięcie do sieci @pw.edu.pl
echo "uwierzytelnij się przez e-mail @pw.edu.pl"
tailscale up

# Podpięcie do sieci ZET przy pomocy klucza:
#scp volt:labsk/c4/tailscale.klucz $KeyFile # Pobranie klucza
#$Key = Get-Content $KeyFile                #
#tailscale up -authkey $Key                 #

tailscale status

# Test łączności:
#ping 100.101.102.103                       # Serwer testowy Tailscale
ping var                                    # Serwer LabSK na PW

# Pobranie adresu IP interfejsu:
#$IP = tailscale ip --4
$ID = (Get-NetIPAddress -InterfaceAlias Tailscale* -AddressFamily IPv4).IPAddress

Write-Host -ForegroundColor Green "$IP"

ssh volt "echo $ID > .vpn.id"               # Export pdresu IP do volta:

return

#EoF
