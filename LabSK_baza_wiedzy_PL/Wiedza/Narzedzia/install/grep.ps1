<#
.Synopsis 
    Install grep
.Notes
    2.5.4 jest z 2009. Najnowszy 3.
.Link
    https://learn.microsoft.com/en-gb/powershell/module/microsoft.powershell.utility/select-string
    https://stackoverflow.com/questions/87350/what-are-good-grep-tools-for-windows
    https://github.com/mbuilov/grep-windows
.Notes 
    ato 2023
#>

$URL = "https://github.com/mbuilov/grep-windows/blob/master/grep-3.8-x86.exe"

winget search grep  
<#
Name                     Id                      Version   Match     Source
----------------------------------------------------------------------------
Detective GrepX          9N85KNDD3M7X            Unknown             msstore
grepWin                  StefansTools.grepWin    2.0.1183  Tag: grep winget
The Silver Searcher      JFLarvoire.Ag           2.2.5     Tag: grep winget
GnuWin32: Grep           GnuWin32.Grep           2.5.4     Tag: grep winget
dnGREP                   dnGrep.dnGrep           3.2.242.0 Tag: grep winget
Batch RegEx Free Edition BinaryMark.BatchRegEx   5.0       Tag: grep winget
AstroGrep                AstroComma.AstroGrep    4.4.7               winget
RipGrep MSVC             BurntSushi.ripgrep.MSVC 13.0.0              winget
RipGrep GNU              BurntSushi.ripgrep.GNU  13.0.0              winget
#>
winget install GnuWin32.Grep
<#
Found GnuWin32: Grep [GnuWin32.Grep] Version 2.5.4
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://sourceforge.net/projects/gnuwin32/files/grep/2.5.4/grep-2.5.4-setup.exe/download
  ██████████████████████████████  1.81 MB / 1.81 MB
Successfully verified installer hash
Starting package install...
Successfully installed
#>
$grep='${env:ProgramFiles(x86)}\GnuWin32\bin\grep.exe'
Set-Alias grep "$grep"
grep --version
#GNU grep 2.5.4
Add-Content -Value "Set-Alias grep $grep" -Path $PROFILE.CurrentUserAllHosts
return
#EoF