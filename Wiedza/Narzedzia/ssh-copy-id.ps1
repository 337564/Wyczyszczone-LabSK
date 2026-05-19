<#
.Synopsis
    Emulacja ssh-copy-id z Unix-a
.Description
    Kopiuje klucz publiczny na maszynę docelową do pliku ~/.ssh/authorized_keys
    Uwaga: Skrypt jest niepełnym odpowiednikiem ssh-copy-id z Unix-a (man ssh-copy-id)
    Implementuje tylko opcje: -i -l
.Parameter HostName
    [uzytkownik@]maszyna
.Parameter User
    Użytkownik na maszynie docelowej
.Parameter KeyFile
    Plik zawierający klucz. (domyślnie "$HOME\.ssh\id_rsa.pub")
.Example
    ssh-copy-id root@s5
    ssh-copy-id root@10.146.225.3
    ssh-copy-id -i KeyDir\id_rsa.pub stud@s5
    s1 s2 | ssh-copy-id -l root
.Link
    https://github.com/PowerShell/openssh-portable/blob/latestw_all/contrib/ssh-copy-id
    https://www.powershellgallery.com/packages/SSH-Copy-ID/1.1.0
    https://github.com/n8tg/ssh-copy-id
.Notes
    Install-Module ssh-copy-id -Scope AllUsers
.Notes
    ato 2021-2026
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory, ValueFromPipeline = $true)]
    [string]$HostName,										# [uzytkownik@]maszyna

    [Alias('l')]
    [string]$User,

    [Alias('i')]
    [string]$KeyFile = "$HOME\.ssh\id_ed25519.pub"          # $env:USERPROFILE
)
Process {
    if ($HostName.Contains("@")) { $User, $HostName = $HostName -split '@' }
    if (!(Test-Path $KeyFile)) {                            # Check key file is there
        Write-Host "key file $KeyFile not found" -f Red
        return
    }
    $Key = Get-Content $KeyFile
    $CMD = "umask 077; mkdir -p .ssh; grep -Fq '$Key' .ssh/authorized_keys 2>/dev/null || cat >> .ssh/authorized_keys"
    try {
        if ($User) {
            $Key | ssh $HostName -l $User $CMD
        } else {
            $Key | ssh $HostName $CMD
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ssh failed (exit $LASTEXITCODE)" -f Red
        }
    } catch {
        Write-Host "error occurred while installing the key" -f Red
    }
}