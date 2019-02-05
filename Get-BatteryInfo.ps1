<#
.SYNOPSIS
Get current battery state
.DESCRIPTION
Get-BatteryInfo.ps1 gets information about the system battery
    and its current state (charging, runtime, capacity)
.PARAMETER Table
Return results as a table
.NOTES
Windows PowerShell 3.0 Script
Written by Drew Weymouth and Andy Wang
February, 2013
#>
[CmdletBinding()]
param ( [Parameter()][switch]$Table )

$battery = Get-WmiObject Win32_Battery | Select-Object `
    DeviceID, Name, Description, DesignVoltage, `
    EstimatedChargeRemaining, EstimatedRunTime
$battstats = Get-WMIObject -Class BatteryStatus -Namespace root\wmi `
    | Where-Object {$_.Voltage -gt 0} `
    | Select-Object Charging, Discharging, Critical

if (!$battery.DesignVoltage) {
    $state = 'Unavailable'
} elseif ($battstats.Charging) {
    $state = 'Charging'
} elseif ($battstats.Discharging) {
    $state = 'Discharging'
} elseif ($battery.EstimatedChargeRemaining -gt 99) {
    $state = 'Charged'
} else {
    $state = 'Not Charging'
}

$remaining  = $battery.EstimatedChargeRemaining
$runtime    = $battery.EstimatedRunTime

if ($Table) {
    $obj = "" ` | Select-Object -Property DeviceID, Name, Description, `
        Voltage, State, PercentCapacity, TimeRemaining

    $obj.DeviceID = $battery.DeviceID
    $obj.Name = $battery.Name
    $obj.Voltage = $battery.DesignVoltage / 1000
    $obj.Description = $battery.Description
    $obj.State = $state
    $obj.PercentCapacity = $remaining
    if ($state -eq 'Discharging' -and $runtime -lt 1440) {
        $obj.TimeRemaining = $runtime
    }
    return $obj
} else {
    Write-Output ("`nBattery: " + $battery.Name)
    Write-Output ('Voltage: ' + $battery.DesignVoltage / 1000)
    Write-Output "Battery is $state"
    if ($state -eq 'Unavailable') { Write-Output ''; exit }
    if ($state -eq 'Discharging') {
        Write-Output ('Remaining capacity: ' + $remaining + '%')
    } elseif ($state -eq 'Charged') {
        Write-Output 'Running on AC power'
    } else {
        Write-Output ('Percent charged: ' + $remaining + '%')
    }
    if ($state -eq 'Discharging' -and $runtime -lt 1440) {
        Write-Output ('Estimated remaining runtime: ' + $runtime + ' minutes')
    }
    Write-Output ''
}
