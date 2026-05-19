#requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string]$Domain = 'zet.pw.edu.pl',

    # Podaj DNS dostepny przez ZeroTier, np.:
    # pwsh -File .\Set-ZeroTierDns.ps1 -DnsServers 10.147.17.1
    [Parameter(Mandatory = $true)]
    [string[]]$DnsServers
)

$ErrorActionPreference = 'Stop'

$Namespace = ".$Domain"
$RuleComment = "managed: zerotier $Domain"

$zt = Get-NetAdapter |
    Where-Object {
        $_.Status -eq 'Up' -and
        ($_.InterfaceDescription -like '*ZeroTier*' -or $_.Name -like '*ZeroTier*')
    } |
    Select-Object -First 1

# Usun poprzednie reguly zarzadzane tym skryptem.
Get-DnsClientNrptRule |
    Where-Object {
        @($_.Namespace) -contains $Namespace -and
        $_.Comment -eq $RuleComment
    } |
    ForEach-Object {
        Remove-DnsClientNrptRule -Name $_.Name -Force
    }

if (-not $zt) {
    Write-Host "ZeroTier DOWN: usunieto regule DNS dla $Namespace"
    exit 0
}

# FQDN-y typu host.zet.pw.edu.pl beda kierowane do DNS dostepnego przez ZeroTier.
Add-DnsClientNrptRule `
    -Namespace $Namespace `
    -NameServers $DnsServers `
    -Comment $RuleComment

# Krotkie nazwy typu "host" moga byc dopowiadane jako host.zet.pw.edu.pl.
Set-DnsClient `
    -InterfaceIndex $zt.ifIndex `
    -ConnectionSpecificSuffix $Domain `
    -RegisterThisConnectionsAddress $false `
    -UseSuffixWhenRegistering $false

Write-Host "ZeroTier UP: dodano DNS dla $Namespace przez $($DnsServers -join ', ')"
