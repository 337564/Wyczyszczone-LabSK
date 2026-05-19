<#
.Synopsis
    Zmiana hasła użytkownika (jak w systemie Unix)
.Description
    Zmiana hasła własnego lub podanego użytkownika
.Parameter User
    Opcjonalna nazwa użytkownika
.Example
    passwd -User stud
.Link
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/set-localuser
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [string]$User = $USERNAME
)

$ErrorActionPreference = 'Stop'

#$Hasło = "H@aSełKo=2020+1"
#$Password = ConvertTo-SecureString -String $Hasło -AsPlainText –Force

Write-Host -ForegroundColor Green -NoNewline "zmiana hasła użytkownika" 
Write-Host -ForegroundColor Yellow "$User"
$Password = Read-Host -AsSecureString -Prompt "hasło"

Get-LocalUser -Name $User | Set-LocalUser -Password $Password

# Weryfikacja:
Get-LocalUser -Name $User | Select-Object Password* | Format-List 
#EoF