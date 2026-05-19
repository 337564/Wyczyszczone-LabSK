# $PROFILE.CurrentUserAllHosts
# ato@cobi.js  2023

# PSReadLine
Set-PSReadlineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit #ViExit

#Region zmienne
$BIN = "$HOME\OneDrive\PowerShell\bin"                  # $psEditor.Workspace.Path
$ETC = "$env:WinDir\system32\drivers\etc"
$HOSTS = "$ETC\hosts"
$ETHERS = "$ETC\ethers"
$SERVICES = "$ETC\services"
#EndRegion zmienne

Set-Alias sudo gsudo
Set-Alias nvi nvim
Set-Alias vi code
Set-Alias vs code
Set-Alias pkg winget
Set-Alias Edit-Net ncap.cpl
Set-Alias grep2 "${env:ProgramFiles(x86)}\GnuWin32\bin\egrep.exe"   # 2.5.4
Set-Alias g Select-String                               # Jest już sls

# ZeroTier
Set-Alias zt "${env:ProgramFiles(x86)}\ZeroTier\One\zerotier-cli.bat"
$ADM = 'd3ecf5726db603c1'
$SKLEP = 'd5e5fb653735e07a'

function md5 { (Get-FileHash -Algorithm MD5 $args).Hash }
function env { Get-ChildItem Env: | Sort-Object Name }  # środowisko
function path { $env:path -split ';' }

$env:path += ";$HOME\bin"

# Nie może być dla scp!:
#Write-Host $env:ComputerName -f Green 
#EoF