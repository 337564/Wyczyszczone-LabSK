<#
.Synopsis
    Graficzan edycja katalogów udostępnianych przez SMB
.Description
    Otwiera konsolę zarządzania (Microsot Managment Console)
    Displays shared folders, current sessions, and open files.
.Link
    https://docs.microsoft.com/en-us/powershell/module/smbshare
.Notes
    ato 2021
#>

FSMgmt.msc
Get-Command -Module SmbShare | Format-Table -AutoSize

#EoF
