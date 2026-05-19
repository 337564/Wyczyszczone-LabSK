<#
.Synopsis
    Operacje na zmiennej środowiskowej PATH
.Description
    Definuje funkcje: Get-Path Add-Path Del-Path Load-Path Compare-Path
    operujące na zmiennej środowiskowej PATH w środowisku globalnym, użytkownika lub procesu
    (Machine, User, Process)
.Example dodanie:
    Path 
    Path + ~\bin

    Path User
    Path User + ~\bin

    Path Machine + c:\tmp\bin
    Path Machine - c:\tmp\bin

    Get-Path User
    Add-Path -Path "$HOME/bin" -Container User
    Reload-Path
.Example usunięcie:
    Get-EnvPath User
    Remove-Path -Path "$HOME/bin" -Container User
    Reload-Path
.Link dokumentacja:
    Doc-Env.ps1
    http://xahlee.info/powershell/environment_variables.html
    https://gist.github.com/mkropat/c1226e0cc2ca941b23a9
    https://gist.github.com/Jaykul/79e7e86b24b3af68aef59bd98c9279fc
.Link ". plik"
    https://ss64.com/ps/source.html
.Notes TODO
    Przykład zapisu do pliku i odtworzenia z niego.
.Notes
    ato 2019-2021
#>
function Path {
    Param(
        [ValidateSet('', '+', '-', 'load', 'edit')]
        [string] $Command = '',

        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container = 'Process',

        [string] $Path
    )
    $Map = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    switch ($Command) {
      '' {Get-Path -Container $Container }
     '+' {Add-Path -Container $Container -Path $Path }
     '-' {Del-Path -Container $Container -Path $Path }
     'load' {Load-Path }
     'Edit' {
        Get-Path -Container $Container > $file
        $Editor $file
        Load-Path -Container $Container < $file }
    }
}
function Get-Path {
    Param(
        #[Parameter(Mandatory = $true)]
        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container = 'Process'
    )
    $Map = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    [Environment]::GetEnvironmentVariable('Path', $Map[$Container]) -split ';' | Where-Object { $_ }
}
function Add-Path {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container = 'Process'
    )
    $Map = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    $Paths = [Environment]::GetEnvironmentVariable('Path', $Map[$Container]) -split ';'
    if ($Paths -notcontains $Path) {
        $Paths = $Paths + $Path | Where-Object { $_ }
        [Environment]::SetEnvironmentVariable('Path', $Paths -join ';', $Map[$Container])
    }
}
function Del-Path {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container = 'Process'
    )
    $Map = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    $containerType = $Map[$Container]
    $Paths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
    if ($Paths -contains $Path) {
        $Paths = $Paths | Where-Object { $_ -and $_ -ne $Path }
        [Environment]::SetEnvironmentVariable('Path', $Paths -join ';', $containerType)
    }
}
function Load-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', "Machine")
    #if ($env:Path[1] -ne ';') { $env:Path += ';' }
    $env:Path += [System.Environment]::GetEnvironmentVariable('Path', "User")
}
function Compare-Path ($OldPath) {
    Compare-Object -ReferenceObject ($OldPath -split ';') -DifferenceObject ($Env:Path -split ';')
}

# START

write-host -ForegroundColor Green "Get-Path Machine"
Get-Path Machine

write-host -ForegroundColor Green "Get-Path User"
Get-Path User

write-host -ForegroundColor Green "Get-Path Process"
Get-Path Process


write-host -ForegroundColor Green "Funkcje: Get-Path Add-Path Del-Path Reload-Path gotowe do użycia. Np. :"
write-host "Get-Path User"
write-host "Add-Path -Path "`$HOME/bin" -Container User"
write-host "Del-Path -Path "`$HOME/bin" -Container User"

<#
# Test:
write-host  Machine: -ForegroundColor Green
Get-EnvPath Machine
write-host  User: -ForegroundColor Green
Get-EnvPath User
#write-host "Session (= Machine + User):" -ForegroundColor Green
Write-PSFHostColor -String '<c="green">Session </c><c="yellow">(= Machine + User):</c>' # tylko PS7
#Get-EnvPath    # TODO - nie działa - powinno dać:
$env:Path -split ';' | sort
$env:Path += "$HOME/bin"                # Dodanie czasowe w sesji

#Export-ModuleMember -Function *
#Export-ModuleMember -Function Get-EnvPath Add-EnvPath Remove-EnvPath Reload-EnvPath Compare-Path
#>
#EoF