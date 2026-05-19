<#
.Synopsis
    Odpowiednik bcdedit.exe
.Description
    Edit Boot Configuration Data (BCD)
.Link
    https://stackoverflow.com/questions/16903460/bcdedit-bcdstore-and-powershell
.Notes
    Wymaga praw administratora
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator
function List-OS {
    # Names of all the operating systems that the BCD is aware of
    param (
        #OptionalParameters
    )
    $cxOptions = new-object System.Management.ConnectionOptions
    $cxOptions.Impersonation = [System.Management.ImpersonationLevel]::Impersonate
    $cxOptions.EnablePrivileges = $true

    $mgmtScope = new-object System.Management.ManagementScope -ArgumentList "root\WMI", $cxOptions
    $mgmtPath = new-object System.Management.ManagementPath -ArgumentList 'root\WMI:BcdObject.Id="{9dea862c-5cdd-4e70-acc1-f32b344d4795}",StoreFilePath=""'
    $mgmtObject = new-object System.Management.ManagementObject -ArgumentList $mgmtScope, $mgmtPath, $null

    # Determine what elements exist in the object and output their value in HEX format
    #$mgmtObject.EnumerateElementTypes().types | % { "{0:X0}" -f $_ }

    $objBCD = $mgmtObject.GetElement(0x24000001)
    $objElements = $objBCD.GetPropertyValue("Element")

    $strOldID = "{9dea862c-5cdd-4e70-acc1-f32b344d4795}"
    for ($i = 0; $i -lt $objElements.Ids.Count; $i++) {
        $mgmtPath.Path = $mgmtPath.Path.Replace($strOldID, $objElements.Ids[$i])
        $strOldID = $objElements.Ids[$i]
        $objBCDId = new-object System.Management.ManagementObject -ArgumentList $mgmtScope, $mgmtPath, $null
        $strOS = $objBCDId.GetElement(0x12000004)
        $strOS.Element.String
    }
    
}

List-OS
return

$otherboot = bcdedit /enum |
Select-String "path" -Context 2, 0 |
ForEach-Object { $_.Context.PreContext[0] -replace '^identifier +' } |
Where-Object { $_ -ne "{current}" }

<# NUC
PS C:\ # bcdedit /enum
Windows Boot Manager
--------------------
identifier              {bootmgr}
device                  partition=\Device\HarddiskVolume1
description             Windows Boot Manager
locale                  en-US
inherit                 {globalsettings}
default                 {current}
resumeobject            {845b725d-4cda-11e8-b616-e381e910184a}
displayorder            {current}
toolsdisplayorder       {memdiag}
timeout                 30

Windows Boot Loader
-------------------
identifier              {current}
device                  partition=C:
path                    \WINDOWS\system32\winload.exe
description             Windows 10
locale                  en-US
inherit                 {bootloadersettings}
recoverysequence        {845b7260-4cda-11e8-b616-e381e910184a}
displaymessageoverride  Recovery
recoveryenabled         Yes
allowedinmemorysettings 0x15000075
osdevice                partition=C:
systemroot              \WINDOWS
resumeobject            {845b725d-4cda-11e8-b616-e381e910184a}
nx                      OptIn
bootmenupolicy          Standard
hypervisorlaunchtype    Off
#>