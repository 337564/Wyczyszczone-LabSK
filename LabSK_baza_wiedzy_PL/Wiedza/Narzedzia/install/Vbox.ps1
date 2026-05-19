<#
.Synopsis
    Instaluje VirtualBox-a
.Description
    Skrypt instaluje program VirtualBox z pakietem rozszerzeń (ExtensionPack)
.Link
    https://www.virtualbox.org/
    https://community.chocolatey.org/packages/virtualbox
.Link
    https://docs.microsoft.com/en-us/troubleshoot/windows-client/application-management/virtualization-apps-not-work-with-hyper-v
	https://www.virtualbox.org/wiki/Downloads
.Notes
    ato 2021-2025
#>
#Requires -RunAsAdministrator	# Skrypt musi być wykonany przez Administratora systemu
$DOWNLOAD = 'https://download.virtualbox.org/virtualbox'
function Install-byChoco {
	choco install virtualbox -y --params "/ExtensionPack /NoDesktopShortcut"

}
function Install-ExtPack ($VER) {	# Instalacja Oracle Extension Pack: RDP, PXE ROM, NVMe, Disk Encr., VM Encr.
	#$VER= '7.1.8'
	$LIC = 'eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae'	# sha256 ??
	#$url = https://download.virtualbox.org/virtualbox/7.1.8/Oracle_VirtualBox_Extension_Pack-7.1.8.vbox-extpack
	$ExtPack = "Oracle_VirtualBox_Extension_Pack-$VER.vbox-extpack"		# ~40MB
	Set-Location "$HOME\Downloads"
	if (-not(Test-Path $ExtPack)) { curl -LRO "$DOWNLOAD/$VER/$ExtPack" }
	VBM extpack install --replace --accept-license=$LIC $ExtPack
	<#
	Do you agree to these license terms and conditions (y/n)? y
	License accepted. For batch installation add
	--accept-license=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae
	to the VBoxManage command line.
	0%...E_FAIL
	VBoxManage.exe: error: Failed to install "C:\Users\ato\Downloads\Oracle_VirtualBox_Extension_Pack-7.1.8.vbox-extpack"
	VBoxManage.exe: error: Upgrading extension pack 'Oracle VirtualBox Extension Pack' failed because at least one VM is still running
	#>
	Remove-Item $ExtPack
	Set-Location -
}
function Test-VB {
	$vBox = New-Object -ComObject VirtualBox.VirtualBox
	#$vBox | Get-Member *
	$vBox.Version
	#$vBox.Machines |ft -a Name,Description # Lista maszyn
}

# START

$ErrorActionPreference = 'Stop'
winget search virtualbox
<#
Name                 Id                Version Match               Source
-------------------------------------------------------------------------
Oracle VM VirtualBox Oracle.VirtualBox 7.1.8   Moniker: virtualbox winget
#>
winget install Oracle.VirtualBox
#RefreshEnv											# lub Update-SessionEnvironment
Set-Alias VBM "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage"
$VER = VBM --version
write-host -ForegroundColor Green "zainstalowany. Wersja $VER" -NoNewline
#$VBM = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage"
#& $VBM --version
$VER = $VER -replace 'r.*',''						# 7.1.8r168469 -> 7.1.8
Install-ExtPack $VER

# Nadal koliduje ? :
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor
#EoF