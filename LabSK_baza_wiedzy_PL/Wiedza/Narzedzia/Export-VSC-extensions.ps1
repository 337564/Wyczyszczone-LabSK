<#
.Synopsis 
    Lista zainstalowanych rozszerzeń VSC
.Link 
    https://stackoverflow.com/questions/35773299/how-can-you-export-the-visual-studio-code-extension-list
.Notes 
    ato 2023
#>
# VSC

Get-ChildItem "$env:USERPROFILE\.vscode\extensions"

#Write-Host 
code --list-extensions | ForEach-Object { "code.cmd --install-extension $_" }

return

#EoF
<# HUB
# PS:
code --install-extension ms-vscode.powershell-preview
# Nvim:
code --install-extension asvetliakov.vscode-neovim
code --install-extension JulianIaquinandi.nvim-ui-modifier
# SSH config:
code --install-extension chrmarti.ssh
# RouterOS:
code --install-extension devMike.mikrotik-routeros-script
code --install-extension cperezabo.routeros-syntax
#>