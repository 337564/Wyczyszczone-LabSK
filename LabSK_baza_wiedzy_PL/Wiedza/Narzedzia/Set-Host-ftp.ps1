<#
.Synopsis
    Dodanie mapowania statycznego nazwy ftp na adres ip serwera LabSK w sieci ZET.
.Description
    Mapowanie statyczne używane jest jeśli brak mapowania w DNS
    lub chcemy użyć innego adresu niż ten który dostarcza DNS.
.Notes
    ato 2021-2022
#>
#Requires -RunAsAdministrator

function Edit-hosts ($Name, $Ip) { # Dodanie mapowania: name -> ip
    $HOSTS = "$env:windir\System32\drivers\etc\hosts"
    ((Get-Content $HOSTS) -notmatch "^[\d\.]+\s+$Name\s*") + "$Ip`t$Name" |
        Set-Content $HOSTS -Encoding utf8
    #code -r $HOSTS                         # Edycja ręczna
}

# START

#$FTP = "10.146.146.22"                     # Adres serwera ftp w sieci ZET
$FTP = "172.27.213.22"                      # Adres serwera ftp w sieci ZET


if (Test-NetConnection $FTP -CommonTCPPort SMB -InformationLevel Quiet) {
    Write-Host -ForegroundColor Green "Serwer ftp odpowiada."
    Edit-hosts "ftp" "$FTP"                 # Dodanie statycznego mapowania
    ping -n 2 ftp                           # Test mapowania
    net view \\ftp                          # Mapowanie dysku
} else {
    Write-Host -ForegroundColor Red "Brak dostępu do serwera LabSK"
    Write-Host -ForegroundColor Yellow "Proszę zgłosić problem w Temas"
}

#EoF
