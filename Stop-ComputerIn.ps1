<#
.SYNOPSIS
Stops or restarts computer, given int parameter in minutes (default 10)
.DESCRIPTION
Stops or restarts computer, given int parameter in minutes (default 10)
Minute range allowed from 1 to 525599 (1 minute before 1 year).
.NOTES
Windows PowerShell 3.0 script
.EXAMPLE
Stop-ComputerIn -r 15
Creates a scheduled task to run a reboot in 15 minutes and registers it.
#>
[CmdletBinding()]
param (
    [Parameter(Position=0)][ValidateRange(1,525599)][int]$Minutes = 10,
    [Parameter()][switch]$Restart,
    [Parameter()][switch]$Help
)

if ($Help) { Get-Help $MyInvocation.MyCommand.path; exit }

if ($Restart) { $cmdop = 'Restart-Computer' }
else          { $cmdop =    'Stop-Computer' }

$args = "-NoProfile -WindowStyle Hidden -command $cmdop"

# If task exists, remove/overwrite with new one.
Unregister-ScheduledTask -TaskName PowerShell-ScheduledShutdown `
    -Confirm:$false -ErrorAction SilentlyContinue

$date    = (Get-Date).AddMinutes($Minutes)
$trigger = New-ScheduledTaskTrigger -Once -At $date
$action  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $args
$sts     = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
$taskdef = New-ScheduledTask -Action $action -Trigger $trigger -Settings $sts `
            -Description "Scheduled $cmdop from Powershell"

$task = Register-ScheduledTask -TaskName PowerShell-ScheduledShutdown `
    -InputObject $taskdef -ErrorAction Inquire

Write-Output "Scheduled $cmdop at $date."
