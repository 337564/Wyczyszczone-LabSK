<#
.Synopsis
    Instalacja Tailscale
.Description
    Skrypt instaluje program Tailscale
.Link
    https://tailscale.com/
.Notes
    ato 2021, skarzyk1 2023
#>
##Requires -RunAsAdministrator           # Skrypt musi być wykonany przez Administratora systemu

$ErrorActionPreference = 'Stop'

# Poprzednia metoda instalacji:
#choco install tailscale -y --params "/NoDesktopShortcut"
#refreshenv                              # lub Update-SessionEnvironment

# Nowa metoda:
winget install tailscale --scope machine

#EoF
