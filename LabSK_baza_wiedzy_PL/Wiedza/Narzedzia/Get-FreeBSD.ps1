<#
.Synopsis
    Pobranie obrazu ISO systemu FreeBSD
.Link
    https://FreeBSD.org
.Notes
    ato 2021
#>

$URL = "http://zet.pw.edu.pl"           # Serwer LabSK
$PUB = "/pub/FreeBSD"                   #  i jego katalog

# Parametry do ewentualnej poprawy:

$WRK = 'C:\tmp\iso'	                # Katalog docelowy zawierający obrazy iso

$CPU = $env:PROCESSOR_ARCHITECTURE.ToLower()
#$CPU = "amd64"		                # System 64-bitowy
#$CPU = "i386"		                # System 32-bitowy jeśli vbox tylko 32bit

# Wersja LabSK: (ZETiIS PW)
# http://zet.pw.edu.pl/pub/FreeBSD/zetis/mfs/freebsd-mfs-14.0-CURRENT-amd64.iso
$VER = "13.0-RELEASE"	                # Wersja stabilna systemu
$VER = "14.0-CURRENT"	                # Wersja testowa
$DIR = "zetis/mfs" ; $file = "freebsd-mfs-$VER-$CPU.iso"

# Dystrybucja oficjalna (instalator):
# https://download.freebsd.org/ftp/releases/ISO-IMAGES/13.0/FreeBSD-13.0-RELEASE-amd64-bootonly.iso
# http://zet.pw.edu.pl/pub/FreeBSD/releases/ISO-IMAGES/13.0/FreeBSD-13.0-RELEASE-amd64-bootonly.iso
#$VER = "13.0-RELEASE"	                # Release Candidate 3
#$DIR = "releases/$CPU/$CPU/ISO-IMAGES/$($VER -replace '-.*$','')" ; $file = "FreeBSD-$VER-$CPU-bootonly.iso"

function Test-iso {                     # Porównanie sum kontrolnych
    $suma = Get-FileHash -Algorithm MD5 $WRK/$file # Suma kontrolna
    ssh volt "md5 $PUB/$DIR/$file"      # Wersja zdalna
    write-host "MD5 ($WRK\$file) = $(($suma.Hash).ToLower())"
}

# START

mkdir "$WRK" -ErrorAction Ignore        # Bez błędu jeśli katalog już jest

$URL = "$URL$PUB/$DIR"                  # Np. http://zet.pw.edu.pl/pub/FreeBSD/zetis/mfs

if (Test-Path "$WRK/$file") {
    Write-Host -ForegroundColor Green "Weryfikacja ..."
    Test-iso                            # Opcjonalny test poprawnego pobrania
    return
} else {
    write-host -ForegroundColor Yellow "$URL/$file -> $WRK"
    Set-Location "$WRK"
    curl.exe -fLRO "$URL/$file"         # Pobranie z zachowaniem daty
    Set-Location -Path -
}

write-host -ForegroundColor Yellow "Maszyna wymaga min 2G RAMu i jest bez dysku twardego (tzw. LiveCD)"
write-host "Logowanie do maszyny FreeBSD:  user/password: root/zetis"   # zaszyte w obrazie

#write-host "Programy instalowujemy poleceniem pkg. Np. pkg install -y pciutils"

#EoF

<# Przykładowy dziennik:
~ > get-freebsd
http://zet.pw.edu.pl/pub/FreeBSD/zetis/mfs/freebsd-mfs-14.0-CURRENT-amd64.iso -> C:\tmp\iso
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  257M  100  257M    0     0  21.2M      0  0:00:12  0:00:12 --:--:-- 18.5M
Maszyna wymaga min 2G RAMu i jest bez dysku twardego (tzw. LiveCD)
Logowanie do maszyny FreeBSD:  user/password: root/zetis

~ > get-freebsd
Weryfikacja ...
MD5 (/pub/FreeBSD/zetis/mfs/freebsd-mfs-14.0-CURRENT-amd64.iso) = d81c7d43738ef76b424c7f813c6e8f9a
MD5 (C:\tmp\iso\freebsd-mfs-14.0-CURRENT-amd64.iso) = d81c7d43738ef76b424c7f813c6e8f9a

~ > dir C:\tmp\iso
-a---          3/1/2021   3:42 PM  734.324MB archlinux-2021.03.01-x86_64.iso
-a---         3/19/2021   8:48 AM  346.703MB FreeBSD-13.0-RC3-amd64-bootonly.iso
-a---         3/19/2021   8:37 AM  245.721MB freebsd-mfs-13.0-RC3-amd64.iso
#>
