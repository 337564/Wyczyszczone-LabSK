<#
.Synopsis
    Get Windows version info
.Link
    https://stackoverflow.com/questions/7330187/how-to-find-the-windows-version-from-the-powershell-command-line/7330368
    https://www.gaijin.at/en/infos/windows-version-numbers
.Notes
    ato 2021
#>
function Get-WinVer {
    $OS = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $Release = $OS.ReleaseId
    $Build = $OS.CurrentBuild
    $UBR = $OS.UBR

    # Format winver.exe :
    # Microsoft Windows 10 Education
    # Wersja 20H2 (kompilacja systemu operacyjnego: 19042.906)
    Write-Host -ForegroundColor Green "Microsoft" $OS.ProductName #-NoNewline
    Write-Host -ForegroundColor Yellow "Wersja" $OS.DisplayVersion `
    "(kompilacja systemu operacyjnego: $Build.$UBR)"

    # Format:
    # Windows 10 Education 2009 Build 19042 (20H2)
    #Write-Host -ForegroundColor Magenta $OS.ProductName $Release "Build" $Build "($($OS.DisplayVersion))"

    #return $Release, $Build        # 2009 19042
}
Get-WinVer | Out-Null
<#
$OS
SystemRoot                : C:\WINDOWS
BaseBuildRevisionNumber   : 1
BuildBranch               : vb_release
BuildGUID                 : ffffffff-ffff-ffff-ffff-ffffffffffff
BuildLab                  : 19041.vb_release.191206-1406
BuildLabEx                : 19041.1.amd64fre.vb_release.191206-1406
CompositionEditionID      : Enterprise
CurrentBuild              : 19042
CurrentBuildNumber        : 19042
CurrentMajorVersionNumber : 10
CurrentMinorVersionNumber : 0
CurrentType               : Multiprocessor Free
CurrentVersion            : 6.3
EditionID                 : Education
InstallationType          : Client
InstallDate               : 1595122733
ProductName               : Windows 10 Education
ReleaseId                 : 2009
SoftwareType              : System
UBR                       : 906
PathName                  : C:\Windows
ProductId                 : 00328-00000-00000-AA994
DigitalProductId          : {164, 0, 0, 0…}
DigitalProductId4         : {248, 4, 0, 0…}
RegisteredOrganization    :
RegisteredOwner           : Windows User
InstallTime               : 132395963334225679
DisplayVersion            : 20H2
#>
#[System.Environment]::OSVersion.Version.Build          # 19042
#(Get-CimInstance Win32_OperatingSystem).Version        # 10.0.19042
#Get-CimInstance -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption # Microsoft Windows 10 Education
#(Get-ItemProperty -Path $env:windir\system32\hal.dll).VersionInfo.FileVersion     # 10.0.19041.906 (WinBuild.160101.0800)
#systeminfo /fo csv | ConvertFrom-Csv | select OS*, System*, Hotfix* | Format-List
#Get-ComputerInfo -Property Windows*

#EoF