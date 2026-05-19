<#
.Synopsis 
    Instalacja nmap
.Notes 
    ato 2022
#>
winget search nmap   
#Name Id            Version Source
#----------------------------------
#Nmap Insecure.Nmap 7.80    winget
sudo winget install nmap <#
Found Nmap [Insecure.Nmap] Version 7.80
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://nmap.org/dist/nmap-7.80-setup.exe
  ██████████████████████████████  25.6 MB / 25.6 MB
Successfully verified installer hash
Starting package install...
Successfully installed
#>
nmap -v  <#
nmap: The term 'nmap' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again. #>

return 
ls 'C:\Program Files (x86)\Nmap\' <#
    Directory: C:\Program Files (x86)\Nmap
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----          17.02.2023    16:27                licenses
d----          17.02.2023    16:27                nselib
d----          17.02.2023    16:27                py2exe
d----          17.02.2023    16:27                scripts
d----          17.02.2023    16:27                share
-a---          02.08.2019    06:52          71217 3rd-party-licenses.txt
-a---          02.08.2019    06:54         209282 ca-bundle.crt
-a---          02.08.2019    06:52         740693 CHANGELOG
-a---          02.08.2019    06:52          27921 COPYING
-a---          02.08.2019    06:56          26562 COPYING_HIGWIDGETS
-a---          31.07.2019    16:25          15086 icon1.ico
-a---          02.08.2019    06:57        1281608 libeay32.dll
-a---          02.08.2019    06:57         161352 libssh2.dll
-a---          02.08.2019    06:57         435784 ncat.exe
-a---          02.08.2019    06:56           1957 NDIFF_README
-a---          02.08.2019    06:57          29256 ndiff.exe
-a---          02.08.2019    06:52            192 nmap_performance.reg
-a---          02.08.2019    06:52         659575 nmap-mac-prefixes
-a---          02.08.2019    06:52        5002931 nmap-os-db
-a---          02.08.2019    06:52          14579 nmap-payloads
-a---          02.08.2019    06:52           6703 nmap-protocols
-a---          02.08.2019    06:52          49647 nmap-rpc
-a---          02.08.2019    06:52        2461461 nmap-service-probes
-a---          02.08.2019    06:52        1000134 nmap-services
-a---          02.08.2019    06:57        2686536 nmap.exe
-a---          02.08.2019    06:52          31936 nmap.xsl
-a---          02.08.2019    06:57         341576 nping.exe
-a---          02.08.2019    06:52          48404 nse_main.lua
-a---          02.08.2019    06:56        2639872 python27.dll
-a---          02.08.2019    06:52            186 README-WIN32
-a---          02.08.2019    06:57         308808 ssleay32.dll
-a---          02.08.2019    06:58          79136 Uninstall.exe
-a---          02.08.2019    06:56           2261 ZENMAP_README
-a---          02.08.2019    06:57         449608 zenmap.exe
-a---          02.08.2019    06:57         180296 zlibwapi.dll
#>
& 'C:\Program Files (x86)\Nmap\nmap.exe' -v <#         
Starting Nmap 7.80 ( https://nmap.org ) at 2023-02-17 16:28 ?rodkowoeuropejski czas stand.
Read data files from: C:\Program Files (x86)\Nmap
WARNING: No targets were specified, so 0 hosts scanned.
Nmap done: 0 IP addresses (0 hosts up) scanned in 0.11 seconds
           Raw packets sent: 0 (0B) | Rcvd: 0 (0B)
#>