<#
.SYNOPSIS
Get computer stats
.DESCRIPTION
Get-Overall: gets stats of CPU usage, memrory, free disk space, networking
Optionally export to csv
.NOTES
Windows PowerShell 3.0 script
.PARAMETER Interval
Controls the amount of time (in seconds) to poll the processor
#>
[CmdletBinding()]
param (
    [Parameter()][ValidateRange(0,300)][int]$Interval = 8
)

$cpu  = Get-Counter -Counter `
            '\Processor(_Total)\% Processor Time' -SampleInterval $Interval
$mem  = Get-Counter -Counter '\Memory\Committed Bytes'
$disk = Get-Counter -Counter '\LogicalDisk(*)\% Free Space'

$row = New-Object PSObject -Property `
  @{
    Timestamp     = get-date; `
    CPU           = ("{0:N2}" -f ($cpu.CounterSamples[0].CookedValue)); `
    Memory_MB     = ("{0:N2}" -f ($mem.CounterSamples[0].CookedValue / 1MB)); `
    PctgDiskFree  = ("{0:N2}" -f ($disk.CounterSamples[0].CookedValue)); `
    Network       = 'unimplemented'; `
  }

return $row | Select-Object Timestamp,CPU,Memory_MB,PctgDiskFree,Network
