<#
.Synopsis
    Windows unfortunately has lots of variations of the SSH clients that may be in your path.
    If you're using the official Windows 10 OpenSSH install, there is a utility you can use to set permissions.
.Link  google -> ssh/config bad owner or permissions windows
    https://github.com/Microsoft/vscode-remote-release/issues/119#issuecomment-489376963
    https://github.com/PowerShell/openssh-portable/blob/latestw_all/contrib/win32/openssh/FixUserFilePermissions.ps1
#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]

param ()
Set-StrictMode -Version 2.0
If ($PSVersiontable.PSVersion.Major -le 2) {$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path}

Import-Module $PSScriptRoot\OpenSSHUtils -Force

if(Test-Path ~\.ssh\config -PathType Leaf)
{
    Repair-UserSshConfigPermission -FilePath ~\.ssh\config @psBoundParameters
}

Get-ChildItem ~\.ssh\* -Include "id_rsa","id_dsa" -ErrorAction SilentlyContinue | % {
    Repair-UserKeyPermission -FilePath $_.FullName @psBoundParameters
}

Write-Host "   Done."
Write-Host " "
