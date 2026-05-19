<#
.Synopsis
    Instalacja zerotier one i podpięcie do sieci ZET
    ST
.Description
    Skrypt wykonuje nastepujące kroki:
     1. Instalacja zerotier-one
     2. Podpięcie do sieci ZET (LabSK)
     3. Eksport parametrów do volta
.Notes
    Uwaga! skrypt zakłada, że działa "ssh volt" bez hasła
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator
#Requires -Version 5.1

$ErrorActionPreference = "Stop"

$Net = "ZET"                                    # Nazwa sieci ZeroTier One
$NetID = "83048a0632d2b7a6"                     # Identyfikator sieci ZET
$FTP = "172.29.146.22"                          # Adres serwera ftp w sieci ZET

$TOKEN = "$env:ProgramData\ZeroTier\One\authtoken.secret"

function Enable-Read ($File) {                  # Danie prawa do odczytu pliku
    $Permission = $env:USERNAME, 'Read', 'Allow'
    $Rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $Permission
    $Acl = Get-Acl -Path $File
    $Acl.SetAccessRule($Rule)                   # Apply new rule
    Set-Acl $File -AclObject $Acl               # https://ss64.com/ps/set-acl.html
}

function Edit-hosts ($Name, $Ip) {              # Dodanie mapowania: name -> ip
    $HOSTS = "$env:windir\System32\drivers\etc\hosts"
    ((Get-Content $HOSTS) -notmatch "^[\d\.]+\s+$Name\s*") + "$Ip`t$Name" |
      Set-Content $HOSTS -Encoding utf8
}

# START

choco install zerotier-one -y                   # Instalacja ZeroTier One
#msiexec /i "C:\Path\To\ZeroTier One.msi"

Enable-Read $TOKEN                              # Dostęp do zerotier-cli

# Potrzebne jeśli nie znajduje zerotierone-cli:
#Update-SessionEnvironment                      # Aktualizacja PATH
refreshenv                                      # alias powyższej funkcji

zerotier-cli join $NetID                        # Podpięcie do sieci ZET

$Info = zerotier-cli info -j | ConvertFrom-Json # Identyfikatora komputera
$ID = $Info.address                             #

$MAC = zerotier-cli get $NetID mac              # Adres MAC interfejsu

# Atomatyczne zarejestrowanie się w sieci: (trwa ok. 5s)
ssh volt zerotier-add $ID $NetID                #

# Po rejestracji pojawi się OK i adres IP:
zerotier-cli listnetworks                       # Weryfikacja
#200 listnetworks <nwid> <name> <mac> <status> <type> <dev> <ZT assigned ips>
#200 listnetworks 83048a0632d2b7a6 ZET a6:c9:ee:5c:f3:f8 OK PRIVATE zt8614a0opd5dt6 172.29.146.22/24
$Status = zerotier-cli get $NetID status
if ($Status -ne "OK") {
    Write-Host -ForegroundColor Red "Brak dostępu do sieci $Net"
    Write-Host -ForegroundColor Yellow "Proszę zgłosić problem w Temas"
} else {
    $IP = zerotier-cli get $NetID ip
    Write-Host -ForegroundColor Green "export ID i MAC do volta"
    ssh volt "echo $ID > .zet.id ; echo $MAC > .zet.mac ; echo $IP > .zet.ip"
    if (Test-NetConnection $FTP -CommonTCPPort SMB -InformationLevel Quiet) {
        Write-Host -ForegroundColor Green "Sieć $Net działa"
        Edit-hosts "ftp" "$FTP"                 # Dodanie statycznego mapowania
        ping -n 2 ftp                           # Test mapowania
        net view \\ftp                          # Mapowanie dysku
    } else {
        Write-Host -ForegroundColor Red "Brak dostępu do serwera LabSK"
        Write-Host -ForegroundColor Yellow "Proszę zgłosić problem w Temas"
    }
}
#EoF
