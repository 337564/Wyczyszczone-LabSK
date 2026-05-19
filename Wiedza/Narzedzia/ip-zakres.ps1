<#
.Synopsis
    Obliczenie parametrów sieci IPv4: min, max, liczba iterfejsów
.Description
    Dla danego argumentu postaci "a.b.c.d/n" obliczamy zakres adresów sieci i liczbę interfejsów
.Link
    https://stackoverflow.com/questions/51296568/powershell-convert-ip-address-to-subnet
.Notes
    [IPAddres] is quite slow and unfortunatley also puts the octet-values in the wrong order.
.Notes
    ato 2021
#>
[CmdletBinding()]
param (
    [Parameter()]
    [string] $IpNet
)
function Net2Mask ($Net) {                          # Zamiana /n na maskę sieci
  $IfMask = (1 -shl (32-$Net)) - 1                  # Maska interfejsu  000011
  $Mask = -Bnot $IfMask                             # Maska Sieci       111100
  #"{0:x8} maska interfejsu`n{1:x} maska sieci" -f $IfMask,$Mask
  return $Mask
}

# START

$IpNet = "10.120.230.177/27"                        # Przykład
$IpNet = "10.2.3.4/27"                        # Przykład

[IPaddress]$Ip, [byte]$Net = $IpNet -Split '/'      # Weryfikacja danych

$IfMask = (1 -shl (32-$Net)) - 1                    # Maska interfejsu  0...000011111
$Mask = -Bnot $Ifmask                               # Maska sieci

$Mask = [UInt32]::MaxValue -shl (32-$Net)           # Alternatywnie

# TODO:
#[IPAddress]$Min = ($Ip.Address -Band $Mask) + [IPAddress]1
#$N =  $IfMask - 1                                   #
#[IPAddress]$Max = $min.Address + $n - 1             #

"$Min"                                              # Implikowana konwersja ToString
$N
$Max.IPAddressToString                              # lub explicite

# https://docs.microsoft.com/en-us/dotnet/api/system.convert.tostring
"{0,32}" -f [Convert]::ToString($IfMask,2)          #                            11111
[Convert]::ToString($Mask,2)                        # 11111111111111111111111111100000
[Convert]::ToString($IP.Address,2)                  # 10110001111001100111100000001010
[Convert]::ToString(($IP.Address -Band $Mask)+1,2)  # 10110001111001100111100000000001

#Eof