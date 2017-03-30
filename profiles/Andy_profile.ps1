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
function rpulldesktop([string]$ip="192.168.1.99", [switch]$nodryrun) {
    if ($nodryrun) { $dryrun = "" } else {
        $dryrun = "--dry-run"
        Write-Output "Dry run. Attempt to connect to $ip (specify -nodryrun to act)"
    }
    Write-Output "Attempting to establish connection to $ip"
    rsync -vaR --delete --progress $dryrun `
        "andy@${ip}:/home/andy/Desktop/andy-pc-sync/./" `
        /cygdrive/c/Users/Andy/Desktop
}

function rpushdesktop([string]$ip="192.168.1.99", [switch]$nodryrun) {
    if ($nodryrun) { $dryrun = "" } else {
        $dryrun = "--dry-run"
        Write-Output "Dry run. Attempt to connect to $ip (specify -nodryrun to act)"
    }
    Write-Output "Attempting to establish connection to $ip"
    #Clean-TemporaryFiles.ps1
    # --exclude '*.bak' --exclude '*.tmp' `
    # --exclude '.git' --exclude '.svn' --exclude '*.temp' --exclude 'desktop.ini' `
    rsync -vaR --delete --progress $dryrun `
        /cygdrive/c/Users/Andy/Desktop/./ `
        "andy@${ip}:~/Desktop/andy-pc-sync/"
}

function rpulldocuments([string]$ip="192.168.1.99", [switch]$nodryrun) {
    if ($nodryrun) { $dryrun = "" } else {
        $dryrun = "--dry-run"
        Write-Output "Dry run. Attempt to connect to $ip (specify -nodryrun to act)"
    }
    Write-Output "Attempting to establish connection to $ip"
    rsync -va --delete --progress $dryrun `
        "andy@${ip}:~/Documents/code" `
        "andy@${ip}:~/Documents/encrypted" `
        "andy@${ip}:~/Documents/misc" `
        "andy@${ip}:~/Documents/music" `
        "andy@${ip}:~/Documents/_work" `
        /cygdrive/d/Documents
}

function rpushdocuments([string]$ip="192.168.1.99", [switch]$nodryrun) {
    if ($nodryrun) { $dryrun = "" } else {
        $dryrun = "--dry-run"
        Write-Output "Dry run. Attempt to connect to $ip (specify -nodryrun to act)"
    }
    Write-Output "Attempting to establish connection to $ip"
    rsync -va --delete --progress $dryrun `
        /cygdrive/d/Documents/code `
        /cygdrive/d/Documents/encrypted `
        /cygdrive/d/Documents/misc `
        /cygdrive/d/Documents/music `
        /cygdrive/d/Documents/_work `
        "andy@${ip}:~/Documents"
}

function rpullmusic([string]$ip="192.168.1.99", [switch]$nodryrun) {
    if ($nodryrun) { $dryrun = "" } else {
        $dryrun = "--dry-run"
        Write-Output "Dry run. Attempt to connect to $ip (specify -nodryrun to act)"
    }
    Write-Output "Attempting to establish connection to $ip"
    rsync -va --delete --progress $dryrun `
        "andy@${ip}:~/Music" `
        /cygdrive/d/Music
}

function rpushmusic([string]$ip="192.168.1.99", [switch]$nodryrun) {
    if ($nodryrun) { $dryrun = "" } else {
        $dryrun = "--dry-run"
        Write-Output "Dry run. Attempt to connect to $ip (specify -nodryrun to act)"
    }
    Write-Output "Attempting to establish connection to $ip"
    rsync -va --delete --progress $dryrun `
        /cygdrive/d/Music `
        "andy@${ip}:~/Music"
}
