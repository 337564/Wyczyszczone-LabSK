<#
.Synopsis
    Obsługa dziennika zadania LabSK
.Description
    Skrypt definuje dwie funkcje: start i stop
    Które rozpoczynają i kończą dziennik pracy nad zadaniem LabSK
.Notes
    ato 2021
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
    [string]$cmd

    [Alias('i')]
    [string]$KeyFile = "$HOME\.ssh\id_rsa.pub"              # $env:USERPROFILE
)

$LOG = 'c:\tmp\file-'
$Date = Get-Date
$log = $LOG + $Date.ToString("yyyy-MM-dd") + ".log"
Get-Date -UFormat "%Y-%m-%d %H:%M:%S"                       # 2021-03-27 22:23:38

Start-Transcript -Path $log -Force

# ............

Stop-Transcript

$log = Get-Content $log

$body = New-Object System.Text.StringBuilder
foreach ($line in $log) {
    [void] $body.AppendLine($line.ToString())
}

# Wysyłka logu:

function Send-Mail {
    $smtp = New-object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($From, $To, $Subject, $Body.ToString())
    if ($cmd = "start") {
        [global]$log$User = $Host.Split("@")[0]
        $Host = $Host.Split("@")[1]
    }
}

if (!(Test-Path $KeyFile)) {
    # Check key file is there
    Write-Warning "key file $KeyFile not found"
    return 1
}
$Key = Get-Content $KeyFile
$CMD = "umask 077; mkdir -p .ssh; grep -Fq '$Key' .ssh/authorized_keys || cat >> .ssh/authorized_keys"
try {
    if ($User) {
        $Key | ssh $Host -l $User $CMD
    }
    else {
        $Key | ssh $Host $CMD
    }
}
catch {
    Write-Host -ForegroundColor Red "ERROR: occurred while installing the key"
    Write-Host $_
}