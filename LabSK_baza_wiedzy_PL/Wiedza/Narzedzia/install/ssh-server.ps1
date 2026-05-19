<#
.Synopsis
    Aktywacja serwera SSH
.Description
.Notes
    The administrators_authorized_keys file must only have permission entries
    for the NT Authority\SYSTEM account and BUILTIN\Administrators security group.
    The NT Authority\SYSTEM account must be granted full control.
    The BUILTIN\Administrators security group is required for administrators
    to manage the authorized keys, you can choose the required access.
    To grant permissions you can open an elevated PowerShell prompt,
    and running the command:
    icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F".
.Link
    https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell
    https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration#configuring-the-default-shell-for-openssh-in-windows
	https://dev.to/tiim/how-to-set-up-an-ssh-server-on-windows-with-wsl-3d96
.Notes
    ato 2023
#>
#Requires -RunAsAdministrator   # Skrypt musi być wykonany przez Administratora systemu

if ((Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Server*' | Select State) -match 'Installed') {
    Write-Host 'OpenSSH.Server jest już zainstalowany' -f Yellow
    return
}

#Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server*
#Path          :
#Online        : True
#RestartNeeded : False

$ConfigDir = "$env:ProgramData/ssh"             #Get-ChildItem $ConfigDir
$AdminKeys = "$ConfigDir/administrators_authorized_keys"
$ServerLog = "$ConfigDir/logs/sshd.log"

New-Item -Path $Admin_Keys -ItemType File
# Zapora
# Confirm the Firewall rule is configured.
# It should be created automatically by setup. Run the following to verify
$Name = "OpenSSH-Server-In-TCP"
if (!(Get-NetFirewallRule -Name $Name -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule '$Name' does not exist, creating it..."
    New-NetFirewallRule -Name $Name -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule '$Name' has been created and exists."
}
Get-NetFirewallRule -Name *OpenSSH-Server* | ft -a #| Select-Object Name,DisplayName,Description,Enabled

# Interpreter = pwsh a nie cmd
#$cmd = "$env:WinDir\System32\WindowsPowerShell\v1.0\powershell.exe"  # Default
#$cmd = "$env:WinDir\System32\bash.exe"                               # WSL
$cmd = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
if (Test-Path -Path $cmd) {
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "$cmd" -PropertyType String -Force
} else {
    Write-Host "brak programu: $cmd" -f Red
    return
}
<#
PS > New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "$cmd" -PropertyType String -Force
DefaultShell : C:\Program Files\PowerShell\7\pwsh.exe
PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH
PSParentPath : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE
PSChildName  : OpenSSH
PSDrive      : HKLM
PSProvider   : Microsoft.PowerShell.Core\Registry#>

# Start the sshd service
Start-Service sshd
#netstat -nao | find /i '":22"'

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

Write-Host "Dziennik serwera jest w pliku: $ServerLog"

# Test
$Key = "$HOME\.ssh\id_ed25519.pub"
if (-not (Test-Path -Path $Key)) { ssh-keygen -t ed25519 }
Copy-Item $Key $HOME\.ssh\authorized_keys
Copy-Item $Key $AdminKeys

ssh localhost

return

# Dla RouterOS tylko RSA:
$Key = "$HOME\.ssh\id_rsa.pub"
if (-not (Test-Path -Path $Key)) { ssh-keygen }

# For Admin user:
if (Test-Admin) {
    New-Item -ItemType SymbolicLink -Path "$HOME/.ssh/administrators_authorized_keys" -Value $AdminKeys
    Get-ChildItem "$HOME/.ssh"
}
return
#Eof
<#
Get-NetFirewallRule -Name *OpenSSH-Server* |select Name, DisplayName, Description, Enabled
Name                  DisplayName               Description                                Enabled
----                  -----------               -----------                                -------
OpenSSH-Server-In-TCP OpenSSH SSH Server (sshd) Inbound rule for OpenSSH SSH Server (sshd)    True

PS C:\Users\ato> sudo
PS C:\Users\ato> $cmd = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
PS C:\Users\ato> New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "$cmd"
DefaultShell : C:\Program Files\PowerShell\7\pwsh.exe
PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH
PSParentPath : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE
PSChildName  : OpenSSH
PSDrive      : HKLM
PSProvider   : Microsoft.PowerShell.Core\Registry
#>