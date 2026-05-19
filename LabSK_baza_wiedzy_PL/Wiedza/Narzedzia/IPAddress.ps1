<#
.Synopsis
    Adresy IPv4 w PowerShell-u
.Description
    PS ma wbudowany typ [IPAddress] !
.Link
    https://networkengineering.stackexchange.com/questions/7106/how-do-you-calculate-the-prefix-network-subnet-and-host-numbers
    https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_operators

    https://stackoverflow.com/questions/51296568/powershell-convert-ip-address-to-subnet

.Notes
    "{0:<s}X}" -f <number or variable>
    [System.String]::Format("{0:X}",<number or variable>)
    [System.Convert]::ToString(<number or variable>,16)
    (<number>).ToString("X")
    <variable>.ToString("X")
.Notes
    ato 2021
#>

# Konwersje string <-> int :
[Convert]::ToInt32("ffffff", 16)                     # Konwersja text hex -> int
[Convert]::ToInt32("111111", 2)                      # Konwersja text bin -> int
[Convert]::ToString($Mask, 2)                        # binarnie -> text bin

# Konversje "ab.c.d" <-> uint32
$ip = [IPAddress]"10.146.225.3"         # OK
$ip = [IPAddress]"310.146.225.3"        # Błąd
$IP_Bramki = " 192.168.1.1 "
$ip = [IPAddress]$IP_Bramki.Trim()      # Nie może być spacji

# Funkcje:
$IPList = Get-content -Path ip-list.txt
$IP = [IPAddress[]]($IPList -match '(?:\d{1,3}\.){3}\d{1,3}').Trim()
function ConvertTo-IPv4MaskString {                 # n -> a.b.c.d
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 32)]
        [Int] $MaskBits
    )
    $mask = ([Math]::Pow(2, $MaskBits) - 1) * [Math]::Pow(2, (32 - $MaskBits))
    $bytes = [BitConverter]::GetBytes([UInt32] $mask)
    (($bytes.Count - 1)..0 | ForEach-Object { [String] $bytes[$_] }) -join "."
}
function ipNr($s) {
    [byte[]]$ip = $s.Split(".")
    [array]::Reverse($ip)
    [bitconverter]::ToUInt32($ip, 0)
}
function ipString($n) {
    $ip = [bitconverter]::GetBytes($n)
    [array]::Reverse($ip)
    [string]::Join(".", $ip)
}
function maskNr($b) {
    (1 -shl $b) - 1 -shl (32 - $b)
}

$Ip = "192.168.100.45"
$PrefixLength = 24
$SubnetId = ipString ((ipNr $Ip) -band (maskNr $PrefixLength))
write-host "$SubnetId/$PrefixLength"
#-----------------------------------------------------------
function ConvertDecimalSubnetMaskToBinary {
    # a.b.c.d -> 11111111 0000000 ...
    $a = $i = $null
    "255.255.128.0" -split '.' | ForEach-Object% {
        $i++
        [string]$a += [Convert]::ToString([int32]$_, 2)
        if ($i -le 3) { [string]$a += "." }
    }
    $a
}
#"{0,9:x8} maska interfejsu`n{1,9:x8} maska sieci" -f $IfMask, $Mask
$IpNet
#-------------------------------------------------------------------------------
# Lista funkci sieciowych:
Get-Command -Module NetTCPIP

# Inspekcja:
Get-NetAdapter | Where-Object { $_.Status -eq "up" }
Get-NetIPConfiguration
Get-NetIPInterface
New-NetIPAddress

# Adres interfejsu:
Get-NetIPInterface
Set-NetIPInterface

# DNS:
$DNS = "1.1.1.1" , "1.0.0.1"                # Cloudflare
$DNS = "8.8.8.8" , "8.8.4.4"                # Google
$DNS = "208.67.222.222" , "208.67.220.220"  # OpenDNS
Set-DnsClientServerAddress

# Tablica tras:
Remove-NetRoute
#>
function Test-IPaddress {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [ValidateScript( { $_ -match [IPAddress]$_ })]
        [string]
        $IPAddress
    )
    Begin {
    }
    Process {
        [IPAddress]$IPAddress
    }
    End {
    }
}


$ipaddr = [System.Net.Dns]::GetHostAddresses('ABCTest-Dev') | Where-Object AddressFamily -eq 'InterNetwork'
Write-Host 'This IPV4 Address of the Host is: '$ipaddr
function ifconfig {
    param (
        OptionalParameters
        $IfName,
        $IP
    )
    # gh about_splatting
    $Args = @{
        InterfaceAlias = $IfName
        #AddressFamily = IPv4
        IPAddress      = $ip
        PrefixLength   = 24
        #DefaultGateway = $Bramka
    }
    New-NetIPAddress $Args
}
# Statycznie:
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1", "8.8.8.8")
# Z DHCP:
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
#EoF