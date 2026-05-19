<#
.Synopsis
    Odnowienie licencji DHCP
.Description
.Link
    http://woshub.com/powershell-configure-windows-networking/  2020
    https://www.pdq.com/blog/using-powershell-to-set-static-and-dhcp-ip-addresses-part-1/
    https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/renewdhcplease-method-in-class-win32-networkadapterconfiguration
    https://powershell.one/wmi/root/cimv2/win32_networkadapterconfiguration-RenewDHCPLease
.Link
    https://docs.microsoft.com/pl-pl/powershell/scripting/samples/performing-networking-tasks?view=powershell-7.1#performing-dhcp-configuration-tasks
.Notes
    ato 2021
#>

# Zwalnianie i odnawianie dzierżaw DHCP na określonych kartach:
# https://docs.microsoft.com/pl-pl/powershell/scripting/samples/performing-networking-tasks?view=powershell-7.1#releasing-and-renewing-dhcp-leases-on-specific-adapters

function Release-DHCP {
    #Get-CimInstance -List | Where-Object {$_.Name -eq 'Win32_NetworkAdapterConfiguration'} |
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration `
        -Filter "IPEnabled=$true and DHCPEnabled=$true" |
        Where-Object { $_.DHCPServer -contains '192.168.1.254' } |
        ForEach-Object -Process { $_.ReleaseDHCPLease() }
}
function Renew-DHCP {
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration `
        -Filter "IPEnabled=$true and DHCPEnabled=$true" |
        Where-Object { $_.DHCPServer -contains '192.168.1.254' } |
        ForEach-Object -Process { $_.RenewDHCPLease() }
}

function Set-DHCP {
    $NA = Get-NetAdapter $Name
    # Disable
    $NA | Set-NetIPInterface -DHCP Disabled
    # Enable:
    $NA |
        Set-NetIPInterface -DHCP Enabled -PassThru |
        Set-DnsClientServerAddress -ResetServerAddresses
    # Enable 2:
    $Adapter = Get-WmiObject win32_NetworkAdapterConfiguration -filter "IPEnabled = 'true'"
    $Adapter.SetDNSServerSearchOrder()  # Configure the DNS Servers automatically
    $Adapter.EnableDHCP()               # Enable DHCP
}
function Set-Metric {
    Get-NetAdapter $Name |
        #Where-Object -FilterScript {$_.LinkSpeed -Eq "100 Mbps"} |
        Set-NetIPInterface -InterfaceMetric 21 -PassThru |
        Set-NetIPInterface -RouterDiscovery ControlledByDHCP    # Disabled Enabled
}
function Set-StaticIP {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces"
    $IP = $builddata.templateIP
    $Mask = $builddata.Subnetmaskbits
    $Gate = $builddata.gateway
    $DNS = $builddata.DNS1, $builddata.DNS2
    $AF = { AddressFamily = IPv4 }
    $Args = @{
        IpAddress      = $IP    #192.168.9.10
        PrefixLength   = $Mask  #24
        DefaultGateway = $Gate  #192.168.9.1
        Confirm        = $false
    }
    $Adapter = Get-NetAdapter -InterfaceIndex 10
    Set-ItemProperty -Path "$RegPath\$($Adapter.InterfaceGuid)" -Name EnableDHCP -Value 0
    $Adaper |
        Remove-NetIPAddress @AF -PassThru |
        Remove-NetRoute @AF -Confirm:$false -PassThru |
        New-NetIPAddress @AF @Args -PassThru |
        Set-DnsClientServerAddress -ServerAddresses $DNS
}
function Renew-DHCP {
    # select the instance(s) for which you want to invoke the method
    # you can use "Get-CimInstance -Query (ADD FILTER CLAUSE HERE!)" to safely play with filter clauses
    # if you want to apply the method to ALL instances, remove "Where...." clause altogether.
    $query = 'Select * From Win32_NetworkAdapterConfiguration Where (ADD FILTER CLAUSE HERE!)'
    Invoke-CimMethod -Query $query -Namespace Root/CIMV2 -MethodName RenewDHCPLease |
        Add-Member -MemberType ScriptProperty -Name ReturnValueFriendly -Passthru -Value {
            switch ([int]$this.ReturnValue) {
                0 { 'Successful completion, no reboot required' }
                1 { 'Successful completion, reboot required' }
                64 { 'Method not supported on this platform' }
                65 { 'Unknown failure' }
                66 { 'Invalid subnet mask' }
                67 { 'An error occurred while processing an Instance that was returned' }
                68 { 'Invalid input parameter' }
                69 { 'More than 5 gateways specified' }
                70 { 'Invalid IP  address' }
                71 { 'Invalid gateway IP address' }
                72 { 'An error occurred while accessing the Registry for the requested information' }
                73 { 'Invalid domain name' }
                74 { 'Invalid host name' }
                75 { 'No primary/secondary WINS server defined' }
                76 { 'Invalid file' }
                77 { 'Invalid system path' }
                78 { 'File copy failed' }
                79 { 'Invalid security parameter' }
                80 { 'Unable to configure TCP/IP service' }
                81 { 'Unable to configure DHCP service' }
                82 { 'Unable to renew DHCP lease' }
                83 { 'Unable to release DHCP lease' }
                84 { 'IP not enabled on adapter' }
                85 { 'IPX not enabled on adapter' }
                86 { 'Frame/network number bounds error' }
                87 { 'Invalid frame type' }
                88 { 'Invalid network number' }
                89 { 'Duplicate network number' }
                90 { 'Parameter out of bounds' }
                91 { 'Access denied' }
                92 { 'Out of memory' }
                93 { 'Already exists' }
                94 { 'Path, file or object not found' }
                95 { 'Unable to notify service' }
                96 { 'Unable to notify DNS service' }
                97 { 'Interface not configurable' }
                98 { 'Not all DHCP leases could be released/renewed' }
                100 { 'DHCP not enabled on adapter' }
                default { 'Unknown Error ' }
            }
        }
}
function Renew-DHCP {

    $ComputerName = 'server12', 'server14'  # adjust to your server names
    $Credential = Get-Credential         # submit a user account with proper permissions

    $session = New-CimSession -ComputerName $ComputerName -Credential $Credential

    # Select the instance(s) for which you want to invoke the method
    # you can use "Get-CimInstance -Query (ADD FILTER CLAUSE HERE!)" to safely play with filter clauses
    $query = 'Select * From Win32_NetworkAdapterConfiguration Where (ADD FILTER CLAUSE HERE!)'
    Invoke-CimMethod -Query $query -Namespace Root/CIMV2 -MethodName RenewDHCPLease -CimSession $session |
        Add-Member -MemberType ScriptProperty -Name ReturnValueFriendly -Passthru -Value {
            switch ([int]$this.ReturnValue) {
                0 { 'Successful completion, no reboot required' }
                1 { 'Successful completion, reboot required' }
                64 { 'Method not supported on this platform' }
                65 { 'Unknown failure' }
                66 { 'Invalid subnet mask' }
                67 { 'An error occurred while processing an Instance that was returned' }
                68 { 'Invalid input parameter' }
                69 { 'More than 5 gateways specified' }
                70 { 'Invalid IP  address' }
                71 { 'Invalid gateway IP address' }
                72 { 'An error occurred while accessing the Registry for the requested information' }
                73 { 'Invalid domain name' }
                74 { 'Invalid host name' }
                75 { 'No primary/secondary WINS server defined' }
                76 { 'Invalid file' }
                77 { 'Invalid system path' }
                78 { 'File copy failed' }
                79 { 'Invalid security parameter' }
                80 { 'Unable to configure TCP/IP service' }
                81 { 'Unable to configure DHCP service' }
                82 { 'Unable to renew DHCP lease' }
                83 { 'Unable to release DHCP lease' }
                84 { 'IP not enabled on adapter' }
                85 { 'IPX not enabled on adapter' }
                86 { 'Frame/network number bounds error' }
                87 { 'Invalid frame type' }
                88 { 'Invalid network number' }
                89 { 'Duplicate network number' }
                90 { 'Parameter out of bounds' }
                91 { 'Access denied' }
                92 { 'Out of memory' }
                93 { 'Already exists' }
                94 { 'Path, file or object not found' }
                95 { 'Unable to notify service' }
                96 { 'Unable to notify DNS service' }
                97 { 'Interface not configurable' }
                98 { 'Not all DHCP leases could be released/renewed' }
                100 { 'DHCP not enabled on adapter' }
                default { 'Unknown Error ' }
            }
        }
    Remove-CimSession -CimSession $session
}
#EoF
