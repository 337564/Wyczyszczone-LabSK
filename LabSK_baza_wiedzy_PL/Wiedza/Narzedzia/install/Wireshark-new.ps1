<#
.Synopsis 
    Instalacja WireShark
.Notes 
    ato 2023
#>

winget search wireshark
<#
Name      Id                            Version Source
-------------------------------------------------------
Wireshark WiresharkFoundation.Wireshark 4.0.3.0 winget #>

#Install\Npcap                         # Bez tego instaluje stary 0.9982 (nowy: 1.72)

sudo winget install wireshark
<#
Found Wireshark [WiresharkFoundation.Wireshark] Version 4.0.3.0
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://www.wireshark.org/download/win64/all-versions/Wireshark-win64-4.0.3.exe
  ██████████████████████████████  75.0 MB / 75.0 MB
Successfully verified installer hash
Starting package install...
Successfully installed
#>
#EoF