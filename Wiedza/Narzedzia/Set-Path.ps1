<#
.Synopsis
    Get-Path Add-Path Remove-Path
.Description
    Definuje funkcje operujące na zmiennej środowiskowej PATH :
    Get-Path Add-Path Remove-Path Reload-Path Compare-Path Edit-Path
    Operuje na środowisku globalnym, użytkownika lub sesji (Machine, User, Session)
.Example dodanie:
    Get-Path User
    Add-Path -Path "$HOME/bin" -Container User
    Reload-Path
.Example usunięcie:
    Remove-Path -Path "$HOME/bin" -Container User
    Reload-Path
.Link dokumentacja:
    Doc-Env.ps1
    http://xahlee.info/powershell/environment_variables.html
    https://gist.github.com/mkropat/c1226e0cc2ca941b23a9
    https://gist.github.com/Jaykul/79e7e86b24b3af68aef59bd98c9279fc
    https://www.tenforums.com/tutorials/121855-edit-user-system-environment-variables-windows.html
.Link ". plik"
    https://ss64.com/ps/source.html
.Notes TODO
    Przykład zapisu do pliku i odtworzenia z niego.
.Notes
    ato 2019-2021
#>
function Get-Path {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Machine', 'User')]
        [string] $Container
    )
    $containerMapping = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
    }
    $containerType = $containerMapping[$Container]

    [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';' |
    Where-Object { $_ }
}
function Add-Path {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )
    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | Where-Object { $_ }
        $env:Path = $envPaths -join ';'
    }
}
function Remove-Path {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )
    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -contains $Path) {
            $persistedPaths = $persistedPaths | Where-Object { $_ -and $_ -ne $Path }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -contains $Path) {
        $envPaths = $envPaths | Where-Object { $_ -and $_ -ne $Path }
        $env:Path = $envPaths -join ';'
    }
}
function Reload-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    #if ($env:Path[1] -ne ';') { $env:Path += ';' }
    $env:Path += [System.Environment]::GetEnvironmentVariable("Path", "User")
}
function Compare-Path ($OldPath) {
    Compare-Object -ReferenceObject ($OldPath -split ';') -DifferenceObject ($Env:Path -split ';')
}
function Edit-Path {
   rundll32.exe sysdm.cpl, EditEnvironmentVariables
}

# START

write-host -ForegroundColor Green "funkcje: Get-Path Add-Path Remove-Path Reload-Path"
write-host -ForegroundColor Yellow "gotowe do użycia. Np. :"
write-host "Get-Path User"
write-host "Add-Path -Path "`$HOME/bin" -Container User"

<#
# Test:
write-host  Machine: -ForegroundColor Green
Get-Path Machine
write-host  User: -ForegroundColor Green
Get-Path User
#write-host "Session (= Machine + User):" -ForegroundColor Green
Write-PSFHostColor -String '<c="green">Session </c><c="yellow">(= Machine + User):</c>' # tylko PS7
#Get-Path    # TODO - nie działa - powinno dać:
$env:Path -split ';' | sort
$env:Path += "$HOME/bin"                # Dodanie czasowe w sesji

#Export-ModuleMember -Function *
#Export-ModuleMember -Function Get-Path Add-Path Remove-Path Reload-Path Compare-Path
#>
#EoF
