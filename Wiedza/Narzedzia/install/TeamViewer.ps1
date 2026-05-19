<#
.Synopsis
    Instalacja programu TeamViewer do udostępniania pulpitu
.Description
    Skrypt instaluje program TeamViewer służący do udostępniania pulpitu
    Instalowana jest wersja "QuickSupport"
.Notes
    Optimized for instant remote desktop support,
    this small customer module does not require installation or administrator rights
    simply download, double click, and give the provided ID and password to your supporter.
.Link
    https://www.teamviewer.com/pl/do-pobrania/windows/
    https://chocolatey.org/packages/teamviewer-qs
    https://download.teamviewer.com/download/TeamViewerQS.exe
.Link wersja pełna
    https://chocolatey.org/packages/teamviewer
    https://download.teamviewer.com/download/TeamViewer_Setup_x64.exe
.Notes
    ato 2021
#>
##Requires -RunAsAdministrator           # Skrypt musi być wykonany przez Administratora systemu

$ErrorActionPreference = 'Stop'

Set-ExecutionPolicy Bypass -Scope Process -Force

choco install teamviewer -y
#choco install teamviewer-qs -y

refreshenv

#& "${env:ProgramFiles(x86)}\TeamViewer\TeamViewer.exe" --info

# Weryfikacja instalacji:
$tv = New-Object -com TeamViewer.Application
$tv.ApiVersion

$TVQS = "$env:ProgramData\chocolatey\lib\teamviewer-qs\tools\TeamViewerQS.exe"

write-host "po uruchomieniu programu przesyłamy swój identyfikator i hasło"

& $TVQS
$T = Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\TeamViewer"
$id = $T,ClientID						# '1333428223'
$pass = 'bp9i54'
# Partner:
#TeamViewer.exe -i $id -P $pass
$tv = new-object -com TeamViewer.Application			# Start (nowe hasło)
$tv.RequestConnectTo ($TvSessionType, $ITvAddress, $Password)

# Dziennik:
ls "$env:AppData\TeamViewer"

# Start poprzedniej sesji:
$dir = "$env:APPDATA\TeamViewer\MRU\RemoteSupport"
ls $dir
<#
Directory:  C:\Users\ato\AppData\Roaming\TeamViewer\MRU\RemoteSupport
Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---        18.05.2020     17:09       71   1333428223.tvc
-a---        20.03.2020     19:53       71   1506327101.tvc
-a---        21.05.2020     17:07       71   1578478821.tvc
-a---        18.05.2020     16:26       71   1666056282.tvc
-a---        18.05.2020     11:54       71   1672039001.tvc
-a---        18.05.2020     13:09       71   1676234984.tvc
-a---        21.05.2020     16:26       71   1807283612.tvc
-a---        21.05.2020     16:38       71   1897048686.tvc
-a---        20.12.2017     01:38       70   299915561.tvc
-a---        04.06.2019     15:53       70   496956145.tvc
#>

# Start a connection (RC/Meeting) to an id specified in given control file (*.tvc).
# Where to find *.tvc files:
# %appdata%\TeamViewer\MRU\RemoteSupport
# %appdata%\TeamViewer\MRU\Meeting

Teamviewer.exe  --control "$dir\abc.tvc"

#EoF