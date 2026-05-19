<#i
.Synopsis
    Instalacja menadżera pakietów Cholatey
    Chocolatey - like pkg, apt, dnf or pacman, but for Windows :-)
.Description
    Skrypt instaluje program choco.exe kóry służy do instalacji i aktualizacji oprogramowania
    w systemie Windows podobnie jak program pkg w systemie Unix FreeBSD, apt w Linux Debian/Ubuntu,
    dnf w Fedora/RedHat, pacman w ArchLinux, czy apk w Linux Alpine
    Instalacja wymaga koniecznie praw Administratora.
.Link instalacja
    https://docs.chocolatey.org/en-us/choco/setup
    https://chocolatey.org/install
.Link źródła
    https://github.com/chocolatey/choco
.Notes
    ato 2021
#>

#Requires -RunAsAdministrator               # Skrypt musi być wykonany przez Administratora systemu

Set-ExecutionPolicy Bypass -Scope Process -Force

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

& $env:ProgramData\chocolatey\bin\choco.exe -v  # weryfikacja - wersja programu (0.11.3)

# Pamiętanie parametrów instalacyjnych przy aktualizacji:
& $env:ProgramData\chocolatey\bin\choco feature enable -n=useRememberedArgumentsForUpgrades

Write-Host -ForegroundColor Green "poleceniem refreshenv możesz aktualizować `$env:PATH :"
Write-Host "refreshenv ; choco -v"

#EoF
