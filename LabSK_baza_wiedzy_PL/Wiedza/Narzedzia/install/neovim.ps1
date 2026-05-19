<#
.Synopsis 
    Instalacja neovim + dodanie go do VSC
.Notes
    Instaluje w $env:ProgramFiles\Neovim
    Dodaje $env:ProgramFiles\Neovim\bin do ścieżki
.Notes
    ato 2023
#>

winget install Neovim.Neovim.Nightly --scope machine

if ($LASTEXITCODE -ne 0 ) {         # Installer hash does not match.
    sudo winget settings --enable InstallerHashOverride 
    winget install Neovim.Neovim.Nightly --scope machine --ignore-security-hash
} 

code --install-extension asvetliakov.vscode-neovim
code --install-extension JulianIaquinandi.nvim-ui-modifier

return
#EoF