<#
.Synopsis
    Instalacja OpenSSH
.Description
    Instalacja najnowszej wersji OpenSSH serwera (sshd) i klienta (ssh)
.Link
    https://github.com/PowerShell/Win32-OpenSSH/issues/1750     # v8.5 in April 2021
    https://www.openssh.com/releasenotes.html                   # 8.5/8.5p1 (2021-03-03)
    https://github.com/PowerShell/openssh-portable
    https://community.chocolatey.org/packages/openssh           #8.0.0.1
    https://gitlab.com/DarwinJS/ChocoPackages/tree/master/openssh
.Notes
    https://github.com/PowerShell/Win32-OpenSSH/wiki/Troubleshooting-Steps
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator               # Skrypt musi być wykonany przez Administratora systemu
function Get-Installed-Version {
    ssh -V                                              # OpenSSH_for_Windows_7.7p1, LibreSSL 2.6.5
    ((Get-Item (Get-Command ssh).Source).VersionInfo.FileVersion)       # 7.7.2.1
    ((Get-Item (Get-Command sshd).Source).VersionInfo.FileVersion)      # 7.7.2.3
}
function Install-OpenSSH {
    choco install OpenSSH -params '"/SSHServerFeature"' -confirm  #--pre
    refreshenv          # lub Update-SessionEnvironment
    Write-Output "Environment refreshed, you should be able to use SSH in this console"
    ssh -V
    Import-Module xxxx.psm1
}
function Install-Choco+OpenSSH {
    # 1. Sets PowerShell Execution Policy to "RemoteSigned"
    # 2. Installs chocolatey package manager
    # 3. Installs the chocolatey package openssh: choco install OpenSSH -params '"/SSHServerFeature"' -confirm
    $URL = 'https://gitlab.com/DarwinJS/ChocoPackages/-/raw/master/openssh/InstallChoco_and_win32-openssh_with_server.ps1'
    Invoke-Expression ((New-object net.webclient).DownloadString($URL))
}
function Install-OpenSSH-NuGet {      # Open a command line on the target (remoting for Nano) and run
    Install-PackageProvider NuGet -ForceBootstrap -Force
    Register-PackageSource -name chocolatey -Provider nuget -Location http://chocolatey.org/api/v2/
    Install-Package openssh -provider NuGet -Force
    $Packages = "$env:ProgramFiles\PackageManagement\NuGet\Packages"
    if (Test-Path "$Packages") {
        $NuGetPkgRoot = "$Packages"
    } else {
        if (Test-Path "$env:ProgramFiles\NuGet\Packages") {
            $NuGetPkgRoot = "$env:ProgramFiles\NuGet\Packages"
        }
    }
    Set-Location ("$NuGetPkgRoot\openssh." + "$((dir "$NuGetPkgRoot\openssh*" |
    %{ [version]$_.name.trimstart('openssh.')} | Sort-Object | Select-Object -last 1) -join '.')\tools")

    & ".\barebonesinstaller.ps1"                            # Client Tools only
    & ".\barebonesinstaller.ps1" -SSHServerFeature          # SSH Server (& client tools)
    & ".\barebonesinstaller.ps1" -SSHServerFeature -SSHServerPort '5555'    # Server on port 5555 (& client tools)
    & ".\barebonesinstaller.ps1" -SSHServerFeature -PathSpecsToProbeForShellEXEString `
    "$env:ProgramFiles\PowerShell*\pwsh.exe;$env:ProgramFiles\PowerShell*\Powershell.exe;$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"

    #$env:ProgramFiles\PowerShell\7\pwsh.exe -WorkingDirectory ~
    #$env:ProgramFiles\PowerShell\7-preview\pwsh.exe -WorkingDirectory ~
    #$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe
}

$ErrorActionPreference = 'Stop'

#EoF