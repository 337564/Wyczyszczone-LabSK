<#
.Synopsis
    Zakres sieci IPv4
.Link
    https://www.reddit.com/r/PowerShell/comments/9us77o/convert_a_string_of_an_ip_range_so_that/
.Notes
    ato 2021
#>

[CmdletBinding()]
Param (
    #[Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    #[ValidateNotNullOrEmpty()]
    [IPAddress]$Ip,
    [IPAddress]$IpMask
)

# Test:
[IPAddress]$IP = '10.120.230.177'
[IPAddress]$Maska = '255.255.255.224'
[IPAddress]$min = $Ip.Address -band $Maska.Address  # .Address = binarnie
"IP min : {0}" -f $min.IPAddressToString


$IpMask = '10.120.230.177/27'
$Ip = $IpMask.Split("/")[0] ; $Maska = $IpMask.Split("/")[1]
"IP: {0}" -f [IPAddress]$Ip.IPAddressToString


#"Mask: {0}" -f [IPAddress]$Maska.IPAddressToString
#$Mask

#EoF