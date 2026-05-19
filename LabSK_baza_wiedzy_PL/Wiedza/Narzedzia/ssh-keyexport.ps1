<#
.Synopsis
    Eksport klucza publicznego ssh
.Description
    Skrypt eksportuje pierwszy zanaleziony klucz publiczny użytkownika do podanych maszyn.
    Działa podobnie do skryptu ssh-copy-id z Unix-a.
    Jeżeli mamy kilka kluczy to parametr -t określa kóry
.Parameter maszyna
    [użytkownik@]maszyna
    Może być z potoku (pipeline) wtedy przy pomocy -l można podać użytkownika
.Parameter t
    Typ klucza (algorytm) : rsa dsa ecdsa ed255519 xmss.
    Jeśli brak to w takiej kolejności poszukiwany jest plik ~/.ssh/id_{typ}.pub
.Parameter l
    Użytkownik na maszynie docelowej jeśli brak [user@]
.Parameter v
    Verbose
.Parameter KeyFile (TODO)
    Plik zawierający klucz.
.Example
    ssh-keyexport volt
.Example
    ssh-keyexport root@10.146.225.3
.Example
    ssh-keyexport -v -t ed25519 user@host       # Verbose + konkretny klucz
.Example
    's1','s2','s3' | ssh-keyexport -v -l root   # do kilku maszyn jednocześnie
.Link
    https://github.com/openssh/openssh-portable/blob/master/contrib/ssh-copy-id
    https://github.com/openssh
.Notes
    ato 2021-2022
#>
[CmdletBinding(HelpUri='http://zet.pw.edu.pl/man?ssh-keyexport.ps1')]
param (
    [Parameter(Position=0, ValueFromPipeline=$true)]
    [string] $user_host,
    [Parameter()]
    [ValidateSet('rsa','dsa','ecdsa','ed25519','xmss')]
    [string] $t = '',
    [string] $l,
    [switch] $v
)
begin {
    $ErrorActionPreference = 'Stop'
    $Algorithm = 'rsa', 'dsa', 'ecdsa', 'ed25519', 'xmss'  # -cert ?
    # Find identity file & set key
    if ($t) { $Algorithm = $t }
    foreach ($alg in $Algorithm) {
        $file = "$HOME\.ssh\id_$alg.pub"
        #Write-Host -ForegroundColor Blue $file
        if (Test-Path $file) {
            $key = Get-Content "$file"
            if ($v) { Write-Host -ForegroundColor Green "export klucza $file" }
            break
        }
    }
    if ( "$key" -eq "") { return 1 }
    $cmd = "umask 077 ; mkdir -p .ssh ; grep -Fqs '$key' .ssh/authorized_keys || echo '$key' >> .ssh/authorized_keys"
    #$cmd_esxi=
    #$cmd_windows=
    if ($v) { Write-Host -ForegroundColor Yellow "$cmd" }
}
process {
    <#
    if ($User_Host -notcontains "@") {
        $User_Host = "$l@$User_Host"
    } else {
        $User = $User_Host.Split("@")[0] ; $Host = $User_Host.Split("@")[1]
    }
    #>
    if ($v) { write-host ssh $user_host "$cmd" }
    $vv = $v ? '-v' : ''
    ssh $vv $user_host "$cmd"
    switch ($LastExitCode) {      # exit code of the last Windows-based program
          0 { Write-Host -ForegroundColor Green "OK"  }
        255 { Write-Host -ForegroundColor Red "^C"  }
    Default { Write-Host -ForegroundColor Red "exit code = $LastExitCode" }
    }
}
end {
}
#EoF
