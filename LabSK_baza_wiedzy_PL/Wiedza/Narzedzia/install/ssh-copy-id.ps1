<#
.Synopsis
    Instalacja polecenia ssh-copy-id
.Link
    https://www.powershellgallery.com/packages/SSH-Copy-ID/1.1.0
    https://github.com/n8tg/ssh-copy-id
.Notes
    ato 2021
#>

#require

Install-Module SSH-Copy-ID -Scope AllUsers

Get-Command -Module SSH-Copy-ID

Get-Help SSH-Copy-ID

<#
Dziennik:
Install-Module SSH-Copy-ID -Scope AllUsers                         11.84s

Get-Command ssh-copy-id
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        ssh-copy-id                                        1.1.0      SSH-Copy-ID
#>