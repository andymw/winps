<#
.SYNOPSIS
Uninstall console fonts
.DESCRIPTION
Uninstalls a font from the set of system console fonts
.PARAM FontName
The name of the font to uninstall
.EXAMPLE
Uninstall-ConsoleFont 'Courier New'
#>
[CmdletBinding()]
param (
    [Parameter(Position=0,Mandatory=$true)][string]$FontName = 'Courier New'
)

$key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont"

# Determine if $FontName is installed as a console font
$installed = Get-ItemProperty $key | Get-Member | `
    Where-Object { $_.Name -match "^0+$" } | `
    Where-Object { $_.Definition -cmatch '=' + $FontName + '$' }

if (!$installed) {
    Write-Output "$FontName is not installed as a console font."; exit
}

# Uninstall the font
Remove-ItemProperty -Path $key -Name $installed.Name
Write-Output "$FontName successfully uninstalled from console fonts."
