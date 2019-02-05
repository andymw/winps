<#
.SYNOPSIS
Gets a list of recent Windows updates
.DESCRIPTION
Returns a list of Windows updates performed within a recent time interval
.PARAMETER RawDisplay
Output data in a raw table rather than formatted for printing
.PARAMETER After
DateTime object specifying the date after which to retrieve updates
(default: 7 days ago)
.PARAMETER Computer
The computer to retrieve update information from
(default: this computer)
.NOTES
Requires PowerShell version 2.0
Copyright Richard J Cox 2009. Use freely at your own risk
Modified by Drew Weymouth
.LINK
http://superuser.com/questions/91305/your-favorite-usefull-powershell-scripts
#>
[CmdletBinding()]
param(
    [switch]$RawDisplay,
    [DateTime]$After = [datetime]::Today.AddDays(-7),
    [string]$Computer = ''
)

$extraArgs = @{}
if ($Computer.Length -gt 0) {
    $extraArgs.Computer = $Computer
}

$events = Get-EventLog -After $after -logname system -InstanceId 19 -source `
    'Microsoft-Windows-WindowsUpdateClient' @extraArgs | `
    Select-Object -property EventId, Index, Source, TimeGenerated, `
    @{n='Message'; e={$_.ReplacementStrings | Select-Object -first 1}}

if ($rawDisplay) {
    $events
} else {
    $events | Format-Table -a -wrap Index, TimeGenerated, Message
}
