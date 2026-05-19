<#
.Synopsis
.Description
.Parameter par
.Example
	Set-DnsSuffix -InterfaceAlias "Ethernet" -Suffix "local"
.Link
	http://jdhitsolutions.com/blog/essential-powershell-resources/
.Notes
	ato 2022
#>
function Set-DnsSuffix {
	param (
		[string]$InterfaceAlias,
		[string]$Suffix
	)
	# Get the network adapter configuration
	$adapter = Get-NetAdapter -Name $InterfaceAlias
	if ($adapter) {
		# Set DNS suffix search list
		$dnsConfig = Get-DnsClientGlobalSetting
		$dnsConfig.SuffixSearchList = $Suffix
		Set-DnsClientGlobalSetting -SuffixSearchList $dnsConfig.SuffixSearchList

		Write-Host "DNS suffix '$Suffix' added successfully to interface '$InterfaceAlias'."
	} else {
		Write-Host "Network adapter '$InterfaceAlias' not found."
	}
}
<# $dnsConfig = Get-DnsClientGlobalSetting ; $dnsConfig |fl *
# VAR
Caption               :
Description           :
ElementName           :
InstanceID            :
AddressOrigin         : 2
ProtocolIFType        :
AppendParentSuffixes  : True
AppendPrimarySuffixes : True
DNSSuffixesToAppend   : {zet.pw.edu.pl}
DevolutionLevel       : 0
SuffixSearchList      : {zet.pw.edu.pl}
UseDevolution         : True
UseSuffixSearchList   : True
PSComputerName        :
CimClass              : ROOT/StandardCimv2:MSFT_DNSClientGlobalSetting
CimInstanceProperties : {Caption, Description, ElementName, InstanceID…}
CimSystemProperties   : Microsoft.Management.Infrastructure.CimSystemProperties
# K227
DNSSuffixesToAppend   : {}
SuffixSearchList      : {}
UseSuffixSearchList   : False #>
