<#
.Synopsis
	Instalacja skryptu IP-Calc
.Link
	https://www.powershellgallery.com/packages/IP-Calc/3.1.0
.Notes
	ato 2023
#>

gsudo Install-Script -Name IP-Calc -Scope AllUsers #-Verbose

IP-Calc 10.146.0.0/16		# Test

return
<#
  ~ > Install-Script -Name IP-Calc -Scope AllUsers -Verbose
Install-Script: Administrator rights are required to install scripts in 'C:\Program Files\PowerShell\Scripts'. Log on to the computer with an account that has Administrator rights, and then try again, or install 'C:\Users\ato\OneDrive\Documents\PowerShell\Scripts' by adding "-Scope CurrentUser" to your command. You can also try running the Windows PowerShell session with elevated rights (Run as Administrator).

~ > gsudo Install-Script -Name IP-Calc -Scope AllUsers -Verbose
VERBOSE: Acquiring providers for assembly: C:\Users\ato\OneDrive\Documents\PowerShell\Modules\PackageManagement\1.4.7\coreclr\netstandard2.0\Microsoft.PackageManagement.CoreProviders.dll
VERBOSE: Acquiring providers for assembly: C:\Users\ato\OneDrive\Documents\PowerShell\Modules\PackageManagement\1.4.7\coreclr\netstandard2.0\Microsoft.PackageManagement.NuGetProvider.dll
VERBOSE: Acquiring providers for assembly: C:\Users\ato\OneDrive\Documents\PowerShell\Modules\PackageManagement\1.4.7\coreclr\netstandard2.0\Microsoft.PackageManagement.MetaProvider.PowerShell.dll
VERBOSE: Acquiring providers for assembly: C:\Users\ato\OneDrive\Documents\PowerShell\Modules\PackageManagement\1.4.7\coreclr\netstandard2.0\Microsoft.PackageManagement.ArchiverProviders.dll
VERBOSE: Cannot find provider 'PowerShellGet' under the specified path.
VERBOSE: Importing package provider 'PowerShellGet'.
VERBOSE: Using the provider 'PowerShellGet' for searching packages.
VERBOSE: The -Repository parameter was not specified.  PowerShellGet will use all of the registered repositories.
VERBOSE: Getting the provider object for the PackageManagement Provider 'NuGet'.
VERBOSE: The specified Location is 'https://www.powershellgallery.com/api/v2/items/psscript' and PackageManagementProvider is 'NuGet'.
VERBOSE: Searching repository 'https://www.powershellgallery.com/api/v2/items/psscript/FindPackagesById()?id='IP-Calc'' for ''.
VERBOSE: Total package yield:'1' for the specified package 'IP-Calc'.
WARNING: Cannot bind argument to parameter 'source' because it is an empty string.
WARNING: Cannot validate argument on parameter 'Location'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again.
WARNING: Cannot bind argument to parameter 'ProviderName' because it is an empty string.
VERBOSE: Performing the operation "Install-Script" on target "Version '3.1.0' of script 'IP-Calc'".
VERBOSE: The installation scope is specified to be 'AllUsers'.
VERBOSE: The specified script will be installed in 'C:\Program Files\PowerShell\Scripts' and its dependent modules will be installed in 'C:\Program Files\PowerShell\Modules'.
VERBOSE: The specified Location is 'NuGet' and PackageManagementProvider is 'NuGet'.
VERBOSE: Downloading script 'IP-Calc' with version '3.1.0' from the repository 'https://www.powershellgallery.com/api/v2/items/psscript'.
VERBOSE: Searching repository 'https://www.powershellgallery.com/api/v2/items/psscript/FindPackagesById()?id='IP-Calc'' for ''.
VERBOSE: InstallPackage' - name='IP-Calc', version='3.1.0',destination='C:\Users\ato\AppData\Local\Temp\1306852559'
VERBOSE: DownloadPackage' - name='IP-Calc', version='3.1.0',destination='C:\Users\ato\AppData\Local\Temp\1306852559\IP-Calc.3.1.0\IP-Calc.3.1.0.nupkg', uri='https://www.powershellgallery.com/api/v2/package/IP-Calc/3.1.0'
VERBOSE: Downloading 'https://www.powershellgallery.com/api/v2/package/IP-Calc/3.1.0'.
VERBOSE: Completed downloading 'https://www.powershellgallery.com/api/v2/package/IP-Calc/3.1.0'.
VERBOSE: Completed downloading 'IP-Calc'.
VERBOSE: InstallPackageLocal' - name='IP-Calc', version='3.1.0',destination='C:\Users\ato\AppData\Local\Temp\1306852559'
VERBOSE: Script 'IP-Calc' was installed successfully to path 'C:\Program Files\PowerShell\Scripts'.

~ > IP-Calc -?
NAME
    C:\Program Files\PowerShell\Scripts\IP-Calc.ps1
SYNOPSIS
SYNTAX
    C:\Program Files\PowerShell\Scripts\IP-Calc.ps1 [-CIDR] <String> [<CommonParameters>]
    C:\Program Files\PowerShell\Scripts\IP-Calc.ps1 [-IPAddress <IPAddress>] -WildCard <IPAddress> [<CommonParameters>]
    C:\Program Files\PowerShell\Scripts\IP-Calc.ps1 [-IPAddress <IPAddress>] -PrefixLength <Int32> [<CommonParameters>]
    C:\Program Files\PowerShell\Scripts\IP-Calc.ps1 [-IPAddress <IPAddress>] -Mask <IPAddress> [<CommonParameters>]
DESCRIPTION
    IP Calculator for calculation IP Subnet
RELATED LINKS
REMARKS
    To see the examples, type: "Get-Help C:\Program Files\PowerShell\Scripts\IP-Calc.ps1 -Examples"
    For more information, type: "Get-Help C:\Program Files\PowerShell\Scripts\IP-Calc.ps1 -Detailed"
    For technical information, type: "Get-Help C:\Program Files\PowerShell\Scripts\IP-Calc.ps1 -Full"

~ >  IP-Calc 10.146.0.0/16
IPAddress    : 10.146.0.0
Mask         : 255.255.0.0
PrefixLength : 16
WildCard     : 0.0.255.255
Subnet       : 10.146.0.0
Broadcast    : 10.146.255.255
CIDR         : 10.146.0.0/16
ToDecimal    : 177340416
#>
