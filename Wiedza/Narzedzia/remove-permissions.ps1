<#
.Synopsis
    Remove all permissions on a folder for a specific user
.Description

.Parameter Path
    Katalog
.Parameter User
    Użytkownik któremu odbieramy rekursywnie prawa
.Notes
    PS C:\Users\ato\Downloads> scp .\routeros-7.7-tile.npk r0:
    Bad permissions. Try removing permissions for user:
    LAPTOP-HUBERT\\Hubert (S-1-5-21-377507912-4293849482-3085929103-1001) on file C:/Users/ato/.ssh/config.
    Bad owner or permissions on C:\\Users\\ato/.ssh/config
.Link
    https://stackoverflow.com/questions/13513863/powershell-remove-all-permissions-on-a-folder-for-a-specific-user
.Notes
    ato 2023
#>

[CmdletBinding()]
param (
    # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
    # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
    # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
    # characters as escape sequences.
    [Parameter(Mandatory = $true, Position = 0,
        #ParameterSetName="LiteralPath",
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Literal path to one or more locations.")]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [string[]]$Path,

    [Parameter(Mandatory = $false, Position = 1,
        HelpMessage = "User Name.")]
    [ValidateNotNullOrEmpty()]
    [string[]]$User = $null,                    # "domain\user"

    [switch]$List
)

# Remove all permissions to a file, except the owner of the file
# https://stackoverflow.com/questions/43623139/remove-all-permissions-to-a-file-except-the-owner-of-the-file
function Remove-ACLEntries {
    [CmdletBinding()]
    param(
        [string]$File
    )
    $AuthUsers = ((New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-11').Translate([System.Security.Principal.NTAccount])).Value
    $acl = Get-Acl $File
    $acl.SetAccessRuleProtection($True, $False)
    $owner = $acl.owner;
    for ($i = $acl.Access.Count - 1; $i -gt 0; $i--) {
        $rule = $acl.Access[$i]
        if ($rule.IdentityReference -ne $owner -or $rule.IdentityReference -eq $AuthUsers) {
            $acl.RemoveAccessRule($rule)
        }
    }
    Set-ACL -Path $File -AclObject $acl | Out-Null
}

# START

#takeown.exe $dir

$ACL = Get-Acl $Path

if ($User -eq $null) { $ACL | Format-List * ; return }

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, "Read", , , "Allow")
$ACL.RemoveAccessRuleAll($AccessRule)
Get-ChildItem $Path -Recurse | Set-Acl -AclObject $ACL

#EoF