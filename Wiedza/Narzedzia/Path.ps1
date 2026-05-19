<#
.Synopsis
    Operacje na zmiennej środowiskowej PATH
	DevHome.EnvironmentVariablesApp.exe
.Description
    Definuje funkcje: Path, {Get, Add, Del, Set, Edit, Compare}-Path
    operujące na zmiennej środowiskowej PATH w środowisku
    globalnym (Maszyna), użytkownika (User) lub bieżącej sesji (Process)
.TODO
	Kasowanie/dodawanie kocowych '\' ;
	https://stackoverflow.com/questions/980255/should-a-directory-path-variable-end-with-a-trailing-slash
.TODO integracja
	Add-ToPaths.ps1
	path-replace.ps1
	Replace-PathEnv.ps1
	Set-EnvPath.ps1
.Parameter Container
    Kontener: 'Machine', 'User', 'Process'
.Parameter Command
    Komenda: '', '+', '-', '='
.Parameter Path,
    Directory
.Parameter Reset
    Reload path
.Parameter Replace
    Replece strings to $env:variable
.Parameter Edit
    Graphical edit
.Example
    path                                    # aktualna wartośc (procerss)
    path User
.Example
    # Dodanie:
    path [clasa] [operacja] [argumenty]
    path + $HOME\bin
    path - $HOME\bin
    path = "C:\a;$HOME\bin"

    path User + ~\bin

    path Machine + c:\tmp\bin
    path Machine - c:\tmp\bin

    Get-Env User
    Set-Env Path "$HOME/bin" -Container User
    Reload-Path
.Example
    # Usunięcie:
    Get-EnvPath User
    Remove-Path -Path "$HOME/bin" -Container User
    Reload-Path
	path | sort							# -Container = Process
	path -Container Machine | sort
	path -Container Machine,User | sort
.Link
    https://docs.microsoft.com/en-us/dotnet/api/system.environmentvariabletarget
    https://trevorsullivan.net/2016/07/25/powershell-environment-variables/
	https://www.techtarget.com/searchitoperations/answer/Manage-the-Windows-PATH-environment-variable-with-PowerShell
    http://xahlee.info/powershell/environment_variables.html
    https://gist.github.com/mkropat/c1226e0cc2ca941b23a9
    https://gist.github.com/Jaykul/79e7e86b24b3af68aef59bd98c9279fc
    https://stackoverflow.com/questions/714877/setting-windows-powershell-environment-variables?rq=1
.Link
    https://ss64.com/ps/source.html					". plik"
    Doc-Env.ps1
.Link
    # Edit environment
    https://www.tenforums.com/tutorials/121855-edit-user-system-environment-variables-windows.html
.Notes
    # TODO
    Przykład zapisu do pliku i odtworzenia z niego.
.Notes
	Używa lokalnego Show-Env.ps1
    ato 2019-2024
#>
[CmdletBinding()]
Param(
    [ValidateSet('', '+', '-', '=', '?')]
    [string]$Command = '',
    [ValidateSet('Machine', 'User', 'Process')]
    [string[]]$Container = 'Process',
    # Directory:
    [string]$Path,
    # Reload path
    [switch]$Reload,
    # Graphical edit
    [switch]$Edit,
    # Replece strings to $env:variable
    [switch]$Replace
)
function Get-Env {                           		# Get Environment Variable
    Param(
        # Environment variable
        [Parameter(Position = 0)]
        #[ValidateNotNull]
        [string]$Name,

        [ValidateSet('Machine', 'User', 'Process')]
        [string]$Container = 'Process'
    )
    $Map = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    [Environment]::GetEnvironmentVariable($Name, $Map[$Container])
}
function Set-Env {									# Set Environment Variable
    Param(
        # Environment Variable Name:
        [Parameter(Mandatory, Position = 0)]
        [string] $Name,
        # Variable Value:
        [Parameter(Mandatory)]
        [string] $Value,

        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container = 'Process'
    )
    $Map = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    if ($Container -eq 'Machine') {
        if (!(Test-Admin)) { throw "you must be Admin to add to $Container" }
    }
    $Paths = Get-Env -Name $Name -Container $Container
    if ($Paths -notcontains $Value) {
        $Paths = $Paths + $Value | Where-Object { $_ }
        [Environment]::SetEnvironmentVariable($Name, $Paths -join ';', $Map[$Container])
    }
    # TODO Dodać do Procesu dla User/Machine ?
}
function Get-Path {                     			# Get Path and split
    Param(
        [string]$Container = 'Process'
    )
    Get-Env -Name 'Path' -Container $Container
}
function Set-Path {
    # Set Path
    Param(
        # Container:
        #[Parameter(AttributeValues)]
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        # Container:
        [string]$Container = 'Process'
    )
    Set-Env -Name Path -Container $Container -Value ($Path -join ';')
}
function Add-Path {
    # Add dir to path
    Param(
        [Parameter(Mandatory)]
        [string[]] $Dir,

        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container = 'Process'
    )
    if (!(Test-Path $Dir)) { throw "folder $Dir does not exist" }
    $Old = Get-Path -Container $Container
    Set-Path -Container $Container -Value $Old,$Path
}
function Del-Path {
    Param(
        [Parameter(Mandatory)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container = 'Process'
    )
    $Map = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    $ContainerType = $Map[$Container]
    $Old = Get-Path $ContainerType
    if ($Old -contains $Path) {
        $New = $Old | Where-Object { $_ -and $_ -ne $Path }
        Set-Path -Container $ContainerType -Value $New
    }
}
function Reload-Path {								# Reload path (skrypt $bin/Reload-Path.ps1
    Write-Host "Resetting path (Machine+User) ..." -f Y
    $Path = Get-Env -Name 'Path' -Container 'Machine'
    if ($Path[-1] -ne ';') { $Path += ';' }
    $env:Path = $Path + (Get-Env -Name 'Path' -Container 'User')
	# Dodawane w $PROFILE :
    $bin = "$HOME/OneDrive/PowerShell/bin"
    $env:path += ";$bin"
	$env:path += ";$env:ProgramFiles\Git\usr\bin"
	#$env:path += ";$env:ProgramFiles\OpenSSH"		# Czy i miejsce
}
function Compare-Path ($OldPath) {
    Compare-Object -ReferenceObject ($OldPath -split ';') -DifferenceObject ($Env:Path -split ';')
}
function Show-Path {
    foreach ($c in $Container) {
        Write-Host ">> $c :" -f Yellow ; Show-Env "$(Get-Path -Container $c)"
    }
}
function Edit-Path {                             	# Edycja graficzna środowiska
    $TempFile = New-TemporaryFile
    Get-Path -Container $Container | Set-Content $Tempfile
    Write-Host -ForegroundColor Yellow "Edit-File $Tempfile"
    Edit-File $Tempfile #-Verbose
    #Out-GridView -PassThru -Title "Edycja Path ($Container)" |
    $S = [IO.Path]::PathSeparator               	# ';' lub ':'
    (Get-Content $TempFile) -join $S | Set-Path -Container $Container
    Remove-Item $TempFile
}

# START

$Map = @{
    Machine = [EnvironmentVariableTarget]::Machine
    User    = [EnvironmentVariableTarget]::User
    Process = [EnvironmentVariableTarget]::Process
}
$S = [IO.Path]::PathSeparator               		# ';' lub ':'

if ($Reload) { Reload-Path ; return }
if ($Edit)   { Edit-Env Path ; return }

switch ($Command) {
    ''  { Show-Path }
    'S' { Get-Path -Container $Container }
    '+' { Add-Path -Container $Container -Path $Path }
    '-' { Del-Path -Container $Container -Path $Path }
    '=' { Set-Path -Container $Container -Path $Path }
    'Edi' { Edit-Path }
}
<#
write-host -ForegroundColor Green "Funkcje: Get-Env Set-Env Del-Path Reload-Path gotowe do użycia. Np. :"
write-host "Get-Env User"
write-host "Set-Env -Path "`$HOME/bin" -Container User"
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