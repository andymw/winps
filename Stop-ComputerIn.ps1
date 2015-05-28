<#
.SYNOPSIS
Stops computer, given int parameter in minutes (Default 10)
.DESCRIPTION
.NOTES
Windows PowerShell 3.0 script
.EXAMPLE
Stop-ComputerIn 15
Creates a scheduled task to run a shutdown in 15 minutes and registers it.
#>
[CmdletBinding()]
param (
    [Parameter(Position=0)][ValidateRange(1,1439)][int]$Minutes = 10,
    [Parameter()][Alias("r")][switch]$Restart,
    [Parameter()][switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

if ($Restart) {
    $operation = 'restart'
    $cmdop = 'Restart-Computer'
} else {
    $operation = 'shutdown'
    $cmdop = 'Stop-Computer'
}

# If task exists, remove/overwrite with new one.
Unregister-ScheduledTask -TaskName PowerShell-ScheduledShutdown `
    -Confirm:$false -ErrorAction SilentlyContinue

Write-Output "Scheduling $operation in $Minutes minutes..."

$date     = (Get-Date).AddMinutes($Minutes)
$trigger  = New-ScheduledTaskTrigger -Once -At $date
$action   = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $cmdop
$sts      = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
$taskdef  = New-ScheduledTask -Action $action -Trigger $trigger -Settings $sts

Register-ScheduledTask -TaskName PowerShell-ScheduledShutdown `
    -InputObject $taskdef -ErrorAction Inquire

Write-Output "Event scheduled for $date."
