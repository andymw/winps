<#
.SYNOPSIS
Run a PowerShell command in the background
.DESCRIPTION
Run a PowerShell command in the background in a new side console window
.PARAMETER Command
The command to run
.PARAMETER ExitImmediately
Exit the background process immediately when the command is complete
    (do not wait for user to press Enter)
.PARAMETER NoWindow
Do not bring up a console window for the background command
    (ExitImmediately is implicitly true)
.EXAMPLE
Run-BackgroundCommand { ls *.txt }
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][ScriptBlock]$Command,
    [Parameter()][switch]$ExitImmediately,
    [Parameter()][switch]$NoWindow
)

$cmd = "-Command $Command; Write-Output `"``n``nDone!`""

if (!$ExitImmediately -and !$NoWindow) {
    $cmd += "; Pause"
}

if ($NoWindow) {
    Start-Process powershell $cmd -WindowStyle Hidden
} else {
    Start-Process powershell $cmd
}
