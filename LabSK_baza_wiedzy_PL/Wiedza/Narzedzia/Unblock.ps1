<#
.Synopsis
	Sprawdzenie czy plik .ps1 pobrany z internetu jest zablokowany
.Description
	Check if the file has the Zone.Identifier stream
	Zone.Identifier alternate data stream, which has a value of 3
	indicate that file was downloaded from the internet.
.Notes
	Objawy:
	Invoke-PathCommand: Error executing $script: File $script cannot be loaded.
	The file $script is not digitally signed.
	You cannot run this script on the current system.
	For more information about running scripts and setting execution policy,
	see about_Execution_Policies
.Example
	Unblock PATH_DIRS_debug.ps1
	Status: file is BLOCKED
	Odblokowanie:
	Unblock-File PATH_DIRS_debug.ps1
.Example
	Unblock PATH_DIRS_debug.ps1 -v
	Status: file is BLOCKED
	Odblokowanie:
	Unblock-File PATH_DIRS_debug.ps1
	Zone.Identifier:
	[ZoneTransfer]
	ZoneId=3
	ReferrerUrl=https://claude.ai/chat/263e68d5-2942-4bb1-8ac8-408957fffea1
	HostUrl=https://claude.ai/api/organizations/b3f2e987-91f0-4d03-8cf3-1614ba9553f2/conversations/263e68d5-2942-4bb1-8ac8-408957fffea1/wiggle/download-file?path=%2Fmnt%2Fuser-data%2Foutputs%2FPATH_DIRS_debug.ps1
	Get-ExecutionPolicy: RemoteSigned
.Link
	https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies
	https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/unblock-file
.Notes
	ato 2025
#>
[CmdletBinding()]
param (
	# Specifies a path to one or more locations.
	[Parameter(Mandatory,
		ValueFromPipeline = $true,
		ValueFromPipelineByPropertyName = $true,
		HelpMessage = "Path to file.")]	# wyświtlane po !?
	[Alias("PSPath")]
	[ValidateNotNullOrEmpty()]
	[string[]]$file,						#$file = "C:\Path\To\YourScript.ps1"
	[switch]$v
)

# START

write-Host 'Status: ' -f Yellow -n
#Get-Item -Path $file -Stream * | Where-Object Stream -EQ 'Zone.Identifier' |
if (Get-Item $file -Stream Zone.Identifier -ErrorAction SilentlyContinue) {
    Write-Host "file is BLOCKED" -f Red
	write-Host 'Odblokowanie: ' -f Green
	write-Host "Unblock-File $file"
	if ($v) {
		write-Host 'Zone.Identifier:' -f Yellow
		Get-Content -Path $File -Stream Zone.Identifier
		write-Host 'Get-ExecutionPolicy: ' -f Yellow -n
		Get-ExecutionPolicy #-Scope CurrentUser
		#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
	}
} else {
    Write-Host "file is NOT blocked" -f Green
}
return
#EoF
Get-ExecutionPolicy -List
<#
        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process          Bypass
  CurrentUser       Undefined
 LocalMachine    RemoteSigned
 #>