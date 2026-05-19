<#
.Synopsis
    Export klucza prywatnego ssh
.Notes 
    ato 2022
#>
function FindKey {
    # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxQF1f83Aa/3ocsBWNequXXr0OiOE5h55U7x3XWD9/2 ato@KUC"
    $Key = Add-Content
    return $Key
}
function TestAdmin {
    Get-LocalGroupMember -Name Administratorzy -Member $env:USERNAME -ErrorAction Ignore
}

# START

$Key = FindKey

Write-Host $Key -f Yellow -NoNewline

if ( TestAdmin ) {
    $File = "$env:ProgramData/ssh/administrators_authorized_keys"
    if (-not Test-Path $File) {
        sudo Add-Content $File $null
        icacls.exe $File /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F".
    }
} else {
    $File = "$HOME/.ssh/authorized_keys"
}

Write-Host $File -f Yellow

#Write-Output $Key >> $File
Add-Content -Path $File -Value $Key

return
#EoF