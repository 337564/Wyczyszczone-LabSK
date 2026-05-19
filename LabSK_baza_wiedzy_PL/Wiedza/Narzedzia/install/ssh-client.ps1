<#
.Synopsis
    Aktywacja clienta SSH w systemie Windows
.Notes
    # Instalacja serwera: bin/install/ssh-server.ps1
.Link
    https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
.Notes
    ato 2023
#>
#Require Admin

Get-WindowsCapability -Online | Select-String ssh
#InputStream:941:Name  : OpenSSH.Client~~~~0.0.1.0
#InputStream:944:Name  : OpenSSH.Server~~~~0.0.1.0
Get-WindowsCapability -Online -Name OpenSSH.Client* #| Select-Object Name,State,DisplayName
<#
Name         : OpenSSH.Client~~~~0.0.1.0
State        : Installed
DisplayName  : Klient OpenSSH
Description  : Oparty na pakiecie OpenSSH klient bezpiecznej powłoki (SSH) umożliwiający bezpieczne zarządzanie kluczami i uzyskiwanie dostępu do komputerów zdalnych.
DownloadSize : 1314377
InstallSize  : 5301296
#>
Add-WindowsCapability -Online -Name OpenSSH.Client*
#Path          :
#Online        : True
#RestartNeeded : False

# Test:
ssh -v

$ConfigDir = "$HOME/.ssh"
#Get-ChildItem $ConfigDir

return 
#Eof