<#
.Synopsis 
    Unix touch
.Notes
    ato 2023
#>
function Set-FileDate {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
        [string[]]$Path,
        [Parameter(Mandatory = $false, Position = 1)]
        [datetime]$NewDate = (Get-Date),
        [switch]$Force
    )
    Get-Item $Path -Force:$Force | ForEach-Object { $_.LastWriteTime = $NewDate }
}

Set-Alias Touch Set-FileDate -Description "Updates the LastWriteTime for the file(s)"

#EoF