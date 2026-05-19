<#
.Synopsis
    Relizacja pierszych kroków ćwiczenia c1 LabSK na komputerze domowym
    w systemie operacyjnyim Windows.
.Description
    Skrypt musi być wykonany w administracyjnej konsoli PowerShell-a:
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex "& { $(irm https://zet.pw.edu.pl/labsk/c1-start.ps1) }"
.Link
    http://zet.pw.edu.pl/labsk/c1
.Notes
    ato 2020
#>
#Requires -RunAsAdministrator           # Skrypt wymaga praw administratora
$ErrorActionPreference = "Stop"

# Uwaga! - poprawić na własne dane ! :
$user = "kowalskj"			            # login na volcie
$LabSK = "c:\labsk"                     # Katalog roboczy LabSK

# START

$volt = "volt.zet.pw.edu.pl"            # Serwer LabSK
$volt = "volt.zet"                      # W sieci ZET 
$volt = "$user@$volt"                   # user@maszyna

# 1. Generacja kluczy

ssh-keygen

# 2. Skopiowanie klucza publicznego na volta

cat "$HOME/.ssh/id_rsa.pub" | ssh $volt 'mkdir .ssh ; cat >> .ssh/authorized_keys'

# 3. Założenia katalogu roboczego i przejscie do niego

mkdir $LabSK ; cd $LabSK

# 4. Skopiowanie skryptów PowerShell-ainstlacji choco vbox-a:

#scp "${volt}:labsk/c1*.ps1" .           # Pobranie plików

# 5. Instalacja oprogramowania

$LABSK = '\\nas2\labsk'
$env:path += "$labsk\bin;$labsk\bin\install"

#bin\install\choco.ps1               # Instalacja programu Chololately
#bin\install\vboxa.ps1               # Instalacja programu VirtualBox
# Teraz jest już winget:
winget install VirtualBox

# 6. Kreacja maszyny wirtualnej

.\c1-pobranie-iso-freebsd.ps1           # Pobranie obrazu iso systemu FreeBSD
.\c1-kreacja-maszyny-freebsd.ps1        # Kreacja maszyny wirtualnej FreeBSD

#EoF