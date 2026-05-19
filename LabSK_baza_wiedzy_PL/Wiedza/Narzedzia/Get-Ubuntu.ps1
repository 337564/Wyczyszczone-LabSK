<#
.Synopsis
    Pobieranie obrazu ISO systemu Ubuntu
.Link
    https://ubuntu.com
.Notes
    ato 2021
#>

$URL = "http://zet.pw.edu.pl/pub/Linux/Ubuntu"

# Parametry do ewentualnej poprawy:

$WRK = 'C:\tmp\iso'                         # Docelowy katalog roboczy na obrazy iso

$CPU = "amd64"                              # System 64-bitowy

$VER = "20.04.2"		            # Wersja stabilna LTS
$VER = "21.04"		                    # Wersja aktualna

$TYP = "desktop"                            # Pulpit graficzny Gnome 2.7G
$TYP = "live-server"                        # Konsola tekstowa 1.1G

# Od komentować jeśli potrzebny jest system 32-bitowy:
#$VER = "16.04.6"
#$CPU = "i386"

# START

$file = "ubuntu-$VER-$TYP-$CPU.iso"

mkdir $WRK -ErrorAction Ignore              # Bez błędu jeśli katalog już jest

Set-Location $WRK

write-host -ForegroundColor Green "pobieranie $URL/$file ..."

curl.exe -fLRO "$URL/$file"

write-host "Maszyna wymaga min 2G RAMu i jest bez dysku twardego (tzw. LiveCD)"
write-host "Logujemy się na nią jako użytkownik ubuntu"

#EoF
