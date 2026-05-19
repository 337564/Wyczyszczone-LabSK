<#
.Synopsis
    Instalacja menadżera pakietów Cholatey
.Link
    https://chocolatey.org/install#individual
.Notes
    Skrypt Wymaga praw Administratora
.Notes
    ato 2021-2023
#>
#Requires -RunAsAdministrator               # Skrypt musi być wykonany przez Administratora systemu

#$Install_Scipt = 'https://chocolatey.org/install.ps1'           # Poprzednio
$Install_Scipt = 'https://community.chocolatey.org/install.ps1'
$Doc = 'https://docs.chocolatey.org/en-us/getting-started'
function Install-Module {
    # C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1
    #Export-ModuleMember -Alias refreshenv -Function 'Update-SessionEnvironment', 'TabExpansion'
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path $ChocolateyProfile) {
        Import-Module $ChocolateyProfile                        # profile (Tab completion)
        # Importing function 'TabExpansion'  'Update-SessionEnvironment'
        # Importing alias 'refreshenv' $ChocolateyInstall\bin\RefreshEnv.cmd # Tylko dla cmd

        #Set-Alias grep "$env:ChocolateyInstall\bin\grep.exe"   # 2.10
        #Set-Alias curl "$env:WINDOWS\system32\curl.exe"        # 7.55.1  411K TODO zblokowany
        #Set-Alias curl "$env:ChocolateyInstall\bin\curl.exe"   # 7.67.0   25K
        #Set-Alias sudo "$env:ChocolateyInstall\bin\Sudo.exe"   #
        $env:Chocolog = "$env:ChocolateyInstall\logs\chocolatey.log"

        gcm -Module chocolateyProfile | ft -a
        #CommandType Name                      Version Source
        #----------- ----                      ------- ------
        #Function    TabExpansion              0.0     chocolateyProfile
        #Function    Update-SessionEnvironment 0.0     chocolateyProfile
    }
}

# START

$ErrorActionPreference = 'Stop'

Set-ExecutionPolicy Bypass -Scope Process -Force

# Instalacja:
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($Install_Scipt))

choco.exe -v                # Chocolatey v0.10.15

# Konfiguracja:
$env:ChocolateyInstall = "$env:ProgramData\chocolatey"
Install-Module
refreshenv                  # lub Update-SessionEnvironment

# To have choco remember parameters on upgrade:
choco feature enable -n=useRememberedArgumentsForUpgrades
#Enabled useRememberedArgumentsForUpgrades

# Dodanie do środowiska
# $code_block >> $profile.AllUsersAllHost
#EoF