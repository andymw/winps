<#
.SYNOPSIS
Gets programs installed on the computer
.DESCRIPTION
Get-Program.ps1 - gets installed programs matching an optional filter
.PARAMETER Name
Filter installed programs by name
.PARAMETER Publisher
Filter installed programs by publisher
.PARAMETER UninstallString
Filter installed programs by uninstall string
.EXAMPLE
Get-Program | Out-GridView
Opens a graphical table of all installed programs on the computer
.EXAMPLE
Get-Program firefox
Returns the installed program entry for Mozilla Firefox
Get-Program -Publisher piriform
Returns entries for all installed programs by Piriform
.LINK
Uninstall-Program.ps1
#>
[CmdletBinding()]
param (
    [Parameter(Position=0)][string]$Name = '?',
    [Parameter()][string]$Publisher = '',
    [Parameter()][string]$UninstallString = '',
    [Parameter()][switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
    HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `

    Select-Object DisplayName, DisplayVersion, Publisher, `
    InstallDate, InstallLocation, HelpLink, UninstallString | `

    Where-Object { $_.DisplayName -like '*'+$Name+'*' -and $_.Publisher -like `
    '*'+$Publisher+'*' -and $_.UninstallString -notlike 'msiexec /package*' `
    -and $_.UninstallString -like '*'+$UninstallString+'*' } | `

    Sort-Object DisplayName,UninstallString -Unique | Sort-Object DisplayName
