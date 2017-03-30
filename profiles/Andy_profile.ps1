<#
.SYNOPSIS
Specifies user profile
.DESCRIPTION
profile.ps1
  performs commands to customize own user profile
  (Previously named Microsoft.PowerShell_profile.ps1)
  (assumes Shorten-String is on the PATH)
.NOTES
Windows PowerShell 3.0 Profile
Andy M. Wang
(assumes Shorten-String is on the PATH)
#>

# Update-Help # download help files

# location variables
$scripts  = "$HOME\Documents\WindowsPowerShell\"

# rm unix conflicts
Remove-Item -Force -ErrorAction SilentlyContinue alias:\diff
Remove-Item -Force -ErrorAction SilentlyContinue alias:\curl
Remove-Item -Force -ErrorAction SilentlyContinue alias:\wget
Remove-Item -Force -ErrorAction SilentlyContinue alias:\sort

# applications
New-Alias -Force -Name npp  'C:\Program Files\Notepad++\notepad++.exe'
New-Alias -Force -Name stc  Stop-Computer

# script aliases (shared)
. Load-ScriptAlias

# backup $PROFILE.CurrentUserAllHosts
function Backup-Profile {
    Copy-Item $PROFILE.CurrentUserAllHosts "$scripts\profiles\Andy_profile.ps1"
}

# prompt
$host.PrivateData.ErrorForegroundColor = 'Green'
function prompt {
    $loc = (Get-Location).ToString()
    Write-Host -Object "$(Get-Date -Format 'HH:mm:ss') PS" `
        -ForegroundColor 'DarkGreen' -NoNewline
    Write-Host -Object " $loc>  " -NoNewline; "`b"
}

# rsyncs
function rpulldesktop([string]$ip="192.168.1.99") {
    Write-Output "Attempting to establish connection to $ip"
    rsync -va --delete --progress `
        "andy@${ip}:~/Desktop/andy-pc-sync/*" `
        /cygdrive/c/Users/Andy/Desktop
}

function rpushdesktop([string]$ip="192.168.1.99") {
    Write-Output "Attempting to establish connection to $ip"
    #Clean-TemporaryFiles.ps1
    # --exclude '*.bak' --exclude '*.tmp' `
    # --exclude '.git' --exclude '.svn' --exclude '*.temp' --exclude 'desktop.ini' `
    rsync -va --delete --progress `
        /cygdrive/c/Users/Andy/Desktop/* `
        "andy@${ip}:~/Desktop/andy-pc-sync/"
}
