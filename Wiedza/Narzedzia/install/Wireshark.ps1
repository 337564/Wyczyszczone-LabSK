<#
.Synopsis
    Instalacja programu Wireshark
.Notes
    Instalacja Wiresharka wymaga uprzedniej instalacji programu Nmap
    (Nmap instaluje automatycznie potrzebną bibliotekę Npcap)
    Można też zainstalować Npcap ręcznie zamiast instalacji Nmap-a.
.Link
    https://www.wireshark.org/
    https://nmap.org/
    https://nmap.org/npcap/dist/npcap-1.31.exe  (2021-04-21)
.Link
    https://community.chocolatey.org/packages/wireshark
    https://community.chocolatey.org/packages/nmap
.Link
    https://github.com/nmap
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator

choco install Nmap -y                       # 7.80  < 7.91
choco install Wireshark -y                  # 3.4.5

# Instalator nie dodaje katalogu do ścieżki. Trzeba to robić ręcznie:
$env:path += ";$env:ProgramFiles\Wireshark"

# Dodanie trwałe - do profilu CurrentUserCurrentHost
echo `n'$env:path += ";$env:ProgramFiles\Wireshark"' >> $PROFILE

# lub zdefiniować alias:
New-Alias tshark "$env:ProgramFiles\Wireshark\tshark"
Add-Content $PROFILE -Value `n'New-Alias tshark "$env:ProgramFiles\Wireshark\tshark"'
Get-Content $PROFILE -Last
return
ll "$env:ProgramFiles\Wireshark\*.exe"      # Zainstalowane programy
<#
-a---        21.04.2021     19:54   332,06KB capinfos.exe
-a---        21.04.2021     19:54    23,56KB dftest.exe
-a---        21.04.2021     19:54   402,56KB dumpcap.exe
-a---        21.04.2021     19:54   346,56KB editcap.exe
-a---        21.04.2021     19:54   320,56KB mergecap.exe
-a---        21.04.2021     19:54    24,06KB mmdbresolve.exe
-a---        21.04.2021     19:54   357,06KB rawshark.exe
-a---        21.04.2021     19:54   316,56KB reordercap.exe
-a---        21.04.2021     19:54   336,56KB text2pcap.exe
-a---        21.04.2021     19:54   548,06KB tshark.exe   <- odpowiednik tcpdump
-a---        21.04.2021     19:54   435,62KB uninstall.exe
-a---        21.04.2021     19:54     8,04MB Wireshark.exe
#>
$PROFILE |fl -f *                           # Inne profile
<#
AllUsersAllHosts       : C:\Program Files\PowerShell\7\profile.ps1
AllUsersCurrentHost    : C:\Program Files\PowerShell\7\Microsoft.VSCode_profile.ps1
CurrentUserAllHosts    : C:\Users\ato\Documents\PowerShell\profile.ps1
CurrentUserCurrentHost : C:\Users\ato\Documents\PowerShell\Microsoft.VSCode_profile.ps1
#>
#EoF