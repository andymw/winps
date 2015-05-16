<#
.Synopsis
    Sets a Windows file association
.Description
    Sets a Windows file association, registering a specific file
    extension to be opened with a specific application
.Parameter Extension
    The extension to register (mandatory)
.Parameter Command
    The command used to open the file, including parameter (mandatory)
.Parameter Description
    The description of the file type to be used in Windows Explorer
    If not given, a default will be created of the form "EXT File"
.Parameter IconPath
    Full path to an icon file to be used for the file type (optional)
.Parameter Handler
    The name of the file type "handler" (e.g. "MyApp_ext")
    If not given, a default will be chosen of the form "EXT_handler"
.Parameter AllUsers
    True if the association should be registered for all users
    Default: current user only
.Example
    Set-FileAssociation -Extension ".txt" -Command "C:\MyTextEditor\MyTextEditor.exe %1"
.Example
     Set-FileAssociation ".txt" "C:\MyTextEditor\MyTextEditor.exe %1" -Description "My Text Editor file" -Handler "MyTextEditor_txt"
.Notes
    Windows PowerShell 2.0 script
    Written by Drew Weymouth
    July, 2013
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,Position=0)][string]$Extension,
    [Parameter(Mandatory=$true,Position=1)][string]$Command,
    [Parameter()][string]$Description,
    [Parameter()][string]$IconPath,
    [Parameter()][string]$Handler,
    [Parameter()][boolean]$AllUsers = $false
)

if ($AllUsers) {
    $basekey = "HKLM\Software\Classes"
} else {
    $basekey = "HKCU\Software\Classes"
}

if (!$Extension.StartsWith(".")) {
    $Extension = "." + $Extension
}
if (!$Description) {
    $Description = $Extension.ToUpper() + " File"
}
if (!$Handler) {
    $Handler = $Extension.ToUpper() + "_handler"
}

REG ADD "$basekey\$Extension" /ve /d "$Handler" /f | Out-Null
REG ADD "$basekey\$Handler" /ve /d "$Description" /f | Out-Null
if ($IconPath) {
    $IconPath = Resolve-Path $IconPath
    REG ADD "$basekey\$Handler\DefaultIcon" /ve /d "$IconPath" /f | Out-Null
}
REG ADD "$basekey\$Handler\shell\Open\Command" /ve /d "$Command" /f | Out-Null

Write-Output "The operation completed successfully."
