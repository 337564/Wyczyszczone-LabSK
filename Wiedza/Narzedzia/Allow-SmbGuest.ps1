<#
.Synopsis
    Umożliwienie zapinania zasobów SMB jako gość
.Description
    Zmiana wartości rejestru umożliwiająca używanie zasobów SMB jako gość
.Link
    https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/guest-access-in-smb2-is-disabled-by-default
    https://superuser.com/questions/244580/getting-access-is-denied-while-using-net-view-command
    https://support.microsoft.com/en-us/help/4046019/guest-access-in-smb2-disabled-by-default-in-windows-10-and-windows-ser
.Notes
    Objawy:
    PS C:\> net view ftp
    System error 53 has occurred.
.Notes
    ato 2020
#>

#Requires -RunAsAdministrator

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"

Get-ItemProperty -Path $RegPath AllowInsecureGuestAuth          # = 0 ?

Set-ItemProperty -Path $RegPath AllowInsecureGuestAuth -Type DWORD -Value 1

Get-ItemProperty -Path $RegPath AllowInsecureGuestAuth          # = 1

Write-host "Teraz trzeba restartować system ręcznie lub poleceniem Restart-Computer"
#Restart-Computer

#EoF
