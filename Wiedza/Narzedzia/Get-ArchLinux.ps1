<#
.Synopsis
    Pobieranie obrazu ISO systemu ArchLinux
.Link
    https://archlinux.org/
    https://wiki.archlinux.org/index.php/Main_page_(Polski)
.Notes
    ato 2021
#>

$URL = "http://zet.pw.edu.pl/pub/Linux/ArchLinux"

# Parametry do ewentualnej poprawy:

$WRK = 'C:\tmp\iso'                     # Docelowy katalog na obrazy iso

$CPU = "x86_64"                         # System 64-bitowy

$VER = "2021.04.01"			            # Wersja
$VER = Get-Date -UFormat "%Y.%m.01"     # Wersja aktualna

$TYP = "archlinux"                      # Standardowa dystrybucja systemu 695M

#$TYP = "aui-console"                   # Konsola tekstowa AUI  948M

# Środowiska graficzne (od komentować wybraną wersję ):

#$TYP = "aui-cinnamon"                  # 1.9G
#$TYP = "aui-deepin"                    # 2.G
#$TYP = "aui-gnome"                     # 1.9G
#$TYP = "aui-i3"                        # 1.5G
#$TYP = "aui-kde"                       # 2.4G
#$TYP = "aui-lxqt"                      # 1.7G
#$TYP = "aui-mate"                      # 1.8G
#$TYP = "aui-xfce"                      # 1.6G

if ( $TYP =~ "^aui*") {                 # Np. aui-console-linux_5_11_10-0327-x64.iso
    $TYP += "-linux"
    $CPU = "x64"
    $URL = "$URL/aui"
    $VER = "5_11_10-0327"
}

$file = "$TYP-$VER-$CPU.iso"

mkdir $WRK -ErrorAction Ignore          # Bez błędu jeśli katalog już jest

Set-Location $WRK

write-host -ForegroundColor Green "pobieranie $URL/$file ..."

curl.exe -fLRO "$URL/$file"

#EoF
