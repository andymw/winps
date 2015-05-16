<#
.SYNOPSIS
Sets or views the system power plans
.DESCRIPTION
When used with no arguments, shows the available and active power plans
When given an argument, changes the currently active power plan.
.NOTES
Windows PowerShell 3.0 script
Written by Drew Weymouth
February 2013
.PARAMETER plan
Sets the current power plan:
  bal/balanced
  hp/highperformance
  ps/powersaver
.PARAMETER help
  View the help screen
.EXAMPLE
Power-Plan
.EXAMPLE
Power-Plan balanced
.EXAMPLE
Power-Plan hp
#>

[CmdletBinding()]
param (
    [Parameter(Position=0)][string]$plan, # TODO ValidatePattern
    [Parameter()][switch]$help
)

if ($help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

if (!$plan) {
    powercfg -list
    Write-Output ''
} elseif ($plan -eq "balanced" -or $plan -eq "bal") {
    powercfg -s 381b4222-f694-41f0-9685-ff5bb260df2e
} elseif ($plan -eq "powersaver" -or $plan -eq "ps") {
    powercfg -s a1841308-3541-4fab-bc81-f71556f20b4a
} elseif ($plan -eq "highperformance" -or $plan -eq "hp") {
    powercfg -s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
} else {
    Write-Output 'Invalid power plan argument'
}
