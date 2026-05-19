<#
.Synopsis
    Pobieranie obrazu ISO systemu Linux Alpine
.Link
    https://alpinelinux.org/
.Notes
    ato 2021

 546M alpine-extended-3.13.5-x86_64.iso
 525M alpine-extended-3.13.5-x86.iso
 133M alpine-standard-3.13.5-x86_64.iso
 122M alpine-standard-3.13.5-x86.iso
  41M alpine-virt-3.13.5-x86_64.iso
  37M alpine-virt-3.13.5-x86.iso
#>

$URL = "http://zet.pw.edu.pl/pub/Linux/Alpine"

# Parametry do ewentualnej poprawy:

$WRK = 'C:\tmp\iso'                     # Docelowy katalog na obrazy iso

$CPU = "x86"                         	# System 32-bitowy
$CPU = "x86_64"                         # System 64-bitowy

$VER = "3.13.5"		                # Wersja

$TYP = "extended"                       # 546M
$TYP = "standard"                       # 133M
$TYP = "virt"                       	# 41M

$file = "alpine-$TYP-$VER-$CPU.iso"	# Np. alpine-extended-3.13.5-x86_64.iso

mkdir $WRK -ErrorAction Ignore          # Bez błędu jeśli katalog już jest

Set-Location $WRK

write-host -ForegroundColor Green "pobieranie $URL/$file ..."

curl.exe -fLRO "$URL/$file"

#EoF
