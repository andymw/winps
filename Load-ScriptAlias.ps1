<#
.SYNOPSIS
loads aliases for scripts
.DESCRIPTION
Load-ScriptAlias loads aliases for scripts
Assumes the named scripts exist on the PATH
script is shared
.NOTES
Windows PowerShell 3.0 script
Drew Weymouth, Andy Wang
#>

New-Alias -Force -Name batchren   -Value Batch-Rename
New-Alias -Force -Name eject      -Value Eject-Drive
New-Alias -Force -Name gmail      -Value Check-Gmail
New-Alias -Force -Name path       -Value Set-Path
New-Alias -Force -Name search     -Value Search-IndexedFiles
New-Alias -Force -Name setenv     -Value Set-EnvironmentVariable

New-Alias -Force -Name o          -Value Invoke-Item
