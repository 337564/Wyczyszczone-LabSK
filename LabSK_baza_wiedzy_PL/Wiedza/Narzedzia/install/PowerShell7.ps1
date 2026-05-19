<#
.Synopsis 
    Install PowerShell 7 on WIndows 11
.Description 
    Przy pomocy winget
.Link 
    https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows
.Notes 
    ato 2023
#>

function Install1 {
    $VER = '7.3.3'
    Set-Location $env:TEMP
    $File = "PowerShell-$VER-win-x64.msi"
    curl.exe -fLRO "https://github.com/PowerShell/PowerShell/releases/download/v$VER/i$File"
    & "./$File"
    Remove-Item $File
    Set-Location -
}
function Install2 {
    # Przepis z VSC PS extension
    iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
}

return 

# Log na Cobi:

winget search Microsoft.PowerShell
<#
The `msstore` source requires that you view the following agreements before using.
Terms of Transaction: https://aka.ms/microsoft-store-terms-of-transaction
The source requires the current machine's 2-letter geographic region to be sent to the backend service to function properly (ex. "US").

Do you agree to all the source agreements terms?
[Y] Yes  [N] No: y
Name       Id                           Version Source
-------------------------------------------------------
PowerShell Microsoft.PowerShell         7.3.2.0 winget
PowerShell Microsoft.PowerShell.Preview 7.4.1.0 winget
#>
winget install Microsoft.PowerShell
<#
Found PowerShell [Microsoft.PowerShell] Version 7.3.2.0
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://github.com/PowerShell/PowerShell/releases/download/v7.3.2/PowerShell-7.3.2-win-x64.msi
  ██████████████████████████████   100 MB /  100 MB
Successfully verified installer hash
Starting package install...
Successfully installed
#>
winget search visualstudiocode <#
Name                                  Id                                  Version Source
-----------------------------------------------------------------------------------------
Microsoft Visual Studio Code Insiders Microsoft.VisualStudioCode.Insiders 1.76.0  winget
Microsoft Visual Studio Code          Microsoft.VisualStudioCode          1.75.1  winget
#>
winget install Microsoft.VisualStudioCode
<#
Found Microsoft Visual Studio Code [Microsoft.VisualStudioCode] Version 1.75.1
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://az764295.vo.msecnd.net/stable/441438abd1ac652551dbe4d408dfcec8a499b8bf/VSCodeUserSetup-x64-1.75.1.exe
  ██████████████████████████████  88.8 MB / 88.8 MB
Successfully verified installer hash
Starting package install...
Successfully installed
#>