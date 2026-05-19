<#
.Synopsis
    Edycja zmiennych środowiskowych
.Description
    Edysja graficzna zmiennych środowiska użytkownika i systemowych
.Link
    https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_environment_variables
    https://www.tenforums.com/tutorials/121855-edit-user-system-environment-variables-windows.html
.Link
    Edit-Path       # edycja zmiennej PATH
.Notes
    ato 2021
#>
##Requires -RunAsAdministrator     # Konieczne dla edycji zmiennych systemowych

rundll32.exe sysdm.cpl, EditEnvironmentVariables

#EoF
