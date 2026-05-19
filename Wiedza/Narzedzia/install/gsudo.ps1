<#
.Synopsis
    Instalacja gsudo
.Description
    Instaluje w "${env:ProgramFiles(x86)}\gsudo" i dodaje katalog do PATH
.Notes
    ato 2023
#>

winget install gsudo --scope machine

# Zrestartować sesję lub aktualizowac $env:PATH

# Konfiguracja:

sudo config CacheDuration "01:00:00"

Write-Host "gsudo cache on   # włączenie kieszeni" -F Yellow

Add-Content "$PROFILE.CurrentUserAllHosts" 'Set-Alias sudo gsudo'

return
<#
PS C:\Users\ato> winget search gsudo
Name  Id             Version Source
------------------------------------
gsudo gerardog.gsudo 2.0.4   winget

PS C:\Users\ato> gcm gsudo -all |ft -a
CommandType Name      Version Source
----------- ----      ------- ------
Application gsudo.exe 0.0.0.0 C:\Program Files (x86)\gsudo\gsudo.exe
Application gsudo     0.0.0.0 C:\Program Files (x86)\gsudo\gsudo

PS C:\Users\ato> grep  sudo $PROFILE.CurrentUserAllHosts
Set-Alias sudo gsudo
#>