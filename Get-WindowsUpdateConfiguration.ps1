<#
.SYNOPSIS
Gets Windows Update Config
.DESCRIPTION
Get-WinUpdateConfig: returns a table of the configuration of Windows Update
    switches: -c  outputs as csv to a given file
              -a  appends to given file (w/ -csv)
.NOTES
Windows PowerShell 3.0 script modified by Andy Wang
.PARAMETER csv
exports to a given file
.PARAMETER append
Used with -csv, appends results to a given file if the file exists
.EXAMPLE
Get-WinUpdateConfig -c 'C:\winUpConfig.csv' -a
#>
[CmdletBinding()]
param (
    [Parameter()][string]$csv,
    [Parameter()][switch]$append,
    [Parameter()][switch]$help
)

if ($help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

$SCRIPT:NotifLevels = @{
    0 = "Not configured";
    1 = "Disabled";
    2 = "Notify before download";
    3 = "Notify before install";
    4 = "Scheduled install"
}

$SCRIPT:AutoUpdateDays = @{
    0 = "Every Day";
    1 = "Sunday";
    2 = "Monday";
    3 = "Tuesday";
    4 = "Wednesday";
    5 = "Thursday";
    6 = "Friday";
    7 = "Saturday"
}

Function Get-WinUpConfig
{
    $AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
    $AUObj = New-Object -TypeName System.Object

    Add-Member -inputObject $AuObj -MemberType NoteProperty -Name "Notif lvl" `
               -Value $NotifLevels[$AUSettings.NotificationLevel]

    Add-Member -inputObject $AuObj -MemberType NoteProperty -Name "Days" `
               -Value $AutoUpdateDays[$AUSettings.ScheduledInstallationDay]

    Add-Member -inputObject $AuObj -MemberType NoteProperty -Name "Hour" `
               -Value $AUSettings.ScheduledInstallationTime

    Add-Member -inputObject $AuObj -MemberType NoteProperty `
               -Name "Recommended updates" -Value $(`
                if ($AUSettings.IncludeRecommendedUpdates) {"Included"} `
                else {"Excluded"})
    $AuObj
}

Function Set-WinUpConfig
{
Param (
[Parameter()][ValidateRange(0,4)][int]$NotifLvl,
[Parameter()][ValidateRange(0,7)][int]$Day,
[Parameter()][ValidateRange(0,24)][int]$hour,
[Parameter()][bool]$InclRecom
)
    $AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
    if ($NotifLvl)  {$AUSettings.NotificationLevel         = $NotifLvl}
    if ($Day)       {$AUSettings.ScheduledInstallationDay  = $Day}
    if ($hour)      {$AUSettings.ScheduledInstallationTime = $hour}
    if ($InclRecom) {$AUSettings.IncludeRecommendedUpdates = $InclRecom}
    $AUSettings.Save()
}

if ($csv) {
    if ($append) {
        Get-WinUpConfig | Export-Csv WinUpdateConfig.csv -noType -append
    } else {
        Get-WinUpConfig | Export-Csv WinUpdateConfig.csv -noType
    }
} else {
    Get-WinUpConfig | Format-Table -AutoSize
}
