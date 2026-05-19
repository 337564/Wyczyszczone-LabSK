<#
.Synopsis
	Instalacja npcap niezbędnego dla Wireshark i nmap.
.Description
	The Npcap installer and uninstaller are easy to use in “Graphical Mode”
	(direct run) and “Silent Mode” (run with /S parameter, available only with Npcap OEM).
.Link
	https://npcap.com/guide/npcap-users-guide.html#npcap-installation
.Notes
	ato 2023
#>
$URL = "https://npcap.com/dist"

# START
#
$VER = 1.72									# TODO: auto

$file = "npcap-$VER.exe"

Set-Location $env:TEMP

curl -sfLRO "$URL/$file"

# Szyki start wireshark-a jak zwykły user (nie prosi o pozwolenie dla każdego interfejsu):
Write-Host "Clear: 'Restrict Npcap drivers access to Administrators only'"
Write-Host "Clear: 'Legacy loopback support'"
Write-Host "Mark:  'Install Npcap in WinPcap API-compatible Mode'"

& ".\$file"

Remove-Item $file

Set-Location -

Get-ChildItem "$env:ProgramFiles\Npcap"

#cat "$env:ProgramFiles\Npcap\NPFInstall.log"

return
#Eof
<# Lon na win11 (lap-hub):
Output folder: C:\Users\ato\AppData\Local\Temp\nsg45EE.tmp
Extract: NPFInstall.exe
Output folder: C:\Program Files\Npcap
Extract: LICENSE
Extract: DiagReport.bat
Extract: DiagReport.ps1
Extract: FixInstall.bat
Extract: Uninstall.exe
Output folder: C:\WINDOWS\system32
Extract: wpcap.dll
Extract: Packet.dll
Extract: NpcapHelper.exe
Extract: WlanHelper.exe
Output folder: C:\WINDOWS\system32\Npcap
Extract: wpcap.dll
Extract: Packet.dll
Extract: NpcapHelper.exe
Extract: WlanHelper.exe
Output folder: C:\Program Files\Npcap
Extract: NPFInstall.exe
Installing NDIS6 x64 driver for Win10
Output folder: C:\Program Files\Npcap
Extract: npcap.sys
Extract: npcap.cat
Extract: npcap.inf
Extract: npcap_wfp.inf
Output folder: C:\WINDOWS\system32
Extract: wpcap.dll
Extract: Packet.dll
Extract: NpcapHelper.exe
Extract: WlanHelper.exe
Output folder: C:\WINDOWS\system32\Npcap
Extract: wpcap.dll
Extract: Packet.dll
Extract: NpcapHelper.exe
Extract: WlanHelper.exe
Output folder: C:\Users\ato\AppData\Local\Temp\nsg45EE.tmp
Extract: roots.p7b
Adding roots.p7b to store "Root"
Delete file: C:\Users\ato\AppData\Local\Temp\nsg45EE.tmp\roots.p7b
Output folder: C:\Users\ato\AppData\Local\Temp\nsg45EE.tmp
Extract: signing.p7b
Adding signing.p7b to store "TrustedPublisher"
Delete file: C:\Users\ato\AppData\Local\Temp\nsg45EE.tmp\signing.p7b
Clearing Npcap entries from driver store
Npcap driver cache in Driver Store has been successfully cleaned up!
Installing WFP callout driver
Npcap WFP callout driver has been successfully installed!
Installing NDIS filter driver
Npcap Packet Driver (NPCAP) (WiFi version) has been successfully installed!
The npcap service was successfully created
Writing service options to registry
Starting the npcap driver
Output folder: C:\Program Files\Npcap
Extract: CheckStatus.bat
Creating npcapwatchdog scheduled task
Scheduled task created.
Completed
#>