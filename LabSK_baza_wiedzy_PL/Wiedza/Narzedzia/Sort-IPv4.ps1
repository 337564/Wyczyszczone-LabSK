<#
.Synopsis
	Sorts IPv4 addresses correctly by converting them to numeric values.
.Description
	Sorts IPv4 addresses or objects containing IPv4 addresses by converting the addresses to numeric values.
	Handles both plain IP addresses and CIDR notation (e.g. "192.168.1.0/24").
	Can sort direct IP strings or object properties containing IP addresses.
.PARAMETER InputObject
	The IP addresses or objects to sort.
.PARAMETER Property
	Property name (supports wildcards) containing IP address if sorting objects.
.PARAMETER Descending
	Sort in descending order.
.Example
	"192.168.1.1", "10.0.0.1", "172.16.1.1" | Sort-IPv4
.Example
	Get-NetRoute | Sort-IPv4 DestinationPrefix | Format-Table -AutoSize
.Example
	"192.168.1.0/24", "10.0.0.0/8", "172.16.0.0/16" | Sort-IPv4 -Descending
.Notes
	ato 2024
#>
[CmdletBinding()]
param(
	[Parameter(ValueFromPipeline = $true)]
	$InputObject,

	[Parameter(Position = 0)]
	[string]$Property,

	[switch]$Descending
)
begin {
	$items = @()
}
process {
	$items += $InputObject
}
end {
	$sorted = $items | Sort-Object -Property {
		$value = if ($Property) {
		$prop = Get-Member -InputObject $_ -MemberType Properties |
			Where-Object Name -Like $Property |
			Select-Object -First 1 -ExpandProperty Name
			$_.$prop
		} else {
			$_
		}
		# Extract IP from CIDR notation if present
		if ($value -match '^([\d\.]+)(/\d+)?$') {
			$ip = $matches[1]
		} else {
			$ip = $value
		}
		# Convert IP to numeric value for sorting
		try {
			$octets = $ip.Split('.')
			[int64]([int64]$octets[0]*16777216 + [int64]$octets[1]*65536 + [int64]$octets[2]*256 + [int64]$octets[3])
		} catch {
			#Write-Warning "Failed to parse IP address: $value"
			[int64]::MaxValue
		}
	} -Descending:$Descending
	return $sorted
}
#EoF