<#
.SYNOPSIS
Install console fonts
.DESCRIPTION
Installs a TTF font as a system console font
.PARAM FontName
The name of the font to install
.EXAMPLE
Install-ConsoleFont 'Courier New'
#>
[CmdletBinding()]
param (
    [Parameter(Position=0, Mandatory=$true)][string]$FontName
)

$key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont"

## Find out if specified font is installed on the system
if (!((Get-Font -Exact $FontName) -cmatch $FontName)) {
    Write-Error "$FontName is not installed on the system."; exit
}

## Determine if $FontName is already installed as a command window font
$installed = Get-ItemProperty $key | Get-Member | `
    Where-Object { $_.Name -match "^0+$" } | `
    Where-Object { $_.Definition -cmatch $FontName }

if ($installed) {
    Write-Output "$FontName is already installed as a console font."; exit
}

## Find out what the largest string of zeros is
$zeros = (Get-ItemProperty $key | Get-Member | `
    Where-Object { $_.Name -match "^0+$" } | Measure-Object).Count

## Install the font
New-ItemProperty $key -Name ("0"*($zeros+1)) -Type string -Value $FontName | Out-Null
Write-Output "$FontName installed successfully as a console font."
