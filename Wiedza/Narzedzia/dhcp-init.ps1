
# Step 1: Identify the ZeroTier interface (e.g., "Ethernet 2" or "zt0")

$ztInterface = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "*ZeroTier*" }

# Step 2: Disable static IP assignment (if configured)

Remove-NetIPAddress -InterfaceIndex $ztInterface.InterfaceIndex -Confirm:$false

# Step 3: Enable DHCP on the ZeroTier interface

Set-NetIPInterface -InterfaceIndex $ztInterface.InterfaceIndex -Dhcp Enabled

# Step 4: Force DHCP renewal (modern method for PowerShell 7.5+)

Restart-NetAdapter -InterfaceDescription $ztInterface.InterfaceDescription -Confirm:$false


# Check assigned IP
Get-NetIPAddress -InterfaceIndex $ztInterface.InterfaceIndex | Format-Table

# Check DHCP server details
Get-DhcpServerv4Lease -ComputerName "YourDHCPServer" | Where-Object ClientId -Match $ztInterface.MacAddress
