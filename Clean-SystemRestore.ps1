<#
.SYNOPSIS
Removes system restore points from the computer
.DESCRIPTION
Removes system restore points from the computer specified by a behavior
    (default behavior: remove all but the most recent restore point)
.PARAMETER Default
The default behavior: remove all but the most recent System Restore point
.PARAMETER Older
Remove all System Restore points older than the specified number of days
.PARAMETER All
Remove all System Restore points
.PARAMETER WhatIf
Don't actually remove restore points, but show what would be removed
.NOTES
Requires Delete-ComputerRestorePoint.ps1 to be available
.EXAMPLE
Clean-SystemRestore
Removes all but the most recent System Restore point
.EXAMPLE
Clean-SystemRestore -Older 7
Removes all restore points more than a week old
#>
[CmdletBinding()]
param (
    [Parameter()][Alias("d")][switch]$Default,
    [Parameter()][Alias("o")][ValidateRange(-1,[int32]::MaxValue)]
        [int]$Older=-1,
    [Parameter()][switch]$All,
    [Parameter()][switch]$WhatIf
)

$restorePoints = Get-ComputerRestorePoint
if (!$restorePoints) {
    Write-Output 'No restore points to remove!'; exit
}

$Default = $Default -or (!$All -and $Older -eq -1)

if ($Default) {
    $restorePoints = $restorePoints[0..($restorePoints.Length - 2)]
} elseif ($Older) {
    $restorePoints = $restorePoints | Where-Object { $_.ConvertToDateTime( `
        $_.CreationTime) -lt (Get-Date).AddDays(-1*$Older) }
}

if ($WhatIf) {
    $restorePoints | Delete-ComputerRestorePoint -WhatIf
} else {
    Write-Output ('Deleting ' + $restorePoints.Length + ' restore points . . .')
    $restorePoints | Delete-ComputerRestorePoint | Out-Null
    Write-Output 'Done!'
}
