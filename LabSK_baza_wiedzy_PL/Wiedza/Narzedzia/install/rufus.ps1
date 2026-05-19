<#
.Synopsis 
    Instalacja rufus-a
.Notes 
    Instaluje w ikatalogu  C:\Program Files\WinGet\Packages\
    Dodaje do ścieżki: C:\Program Files\WinGet\Links
.Notes 
    ato 2023
#>

sudo winget install Rufus.Rufus --scope machine

Get-ChildItem "$env:ProgramFiles\WinGet\Packages"       # Program
Get-ChildItem "$env:ProgramFiles\WinGet\links"          # Link

return
#EoF