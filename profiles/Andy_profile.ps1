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
New-Alias -Force -Name npp  'C:\Program Files (x86)\Notepad++\notepad++.exe'

New-Alias -Force -Name stc  Stop-Computer

# script aliases (shared)
. Load-ScriptAlias

# functions
# pdf word count
<#
function pdfwc([string[]]$pdffiles) {
    foreach ($pdffileitem in $pdffiles) {
        foreach ($pdffile in (Resolve-Path $pdffileitem)) {
            $count = pdftotext "$pdffile" - | wc -w
            Write-Output "$pdffile : $count"
        }
    }
}
#>

# backup $PROFILE.CurrentUserAllHosts
function Backup-Profile {
    Copy-Item $PROFILE.CurrentUserAllHosts "$scripts\profiles\Andy_profile.ps1"
}

<#
# clear sumatra pdf cache
function Clear-SumatraPDFCache {
    Remove-Item -Recurse "C:\Users\Andy\bin\sumatrapdfcache" -ErrorAction SilentlyContinue
    Copy-Item "C:\Users\Andy\bin\SumatraPDF-settings_backup.txt" "C:\Users\Andy\bin\SumatraPDF-settings.txt"
}
#>

# rsync
function rbackup {
    #Clear-SumatraPDFCache
    Clean-TemporaryFiles.ps1
    rsync -va --delete --progress --exclude '*.bak' --exclude '*.tmp' `
        --exclude '.git' --exclude '.svn' --exclude '*.temp' --exclude 'desktop.ini' `
        /cygdrive/c/Users/Andy/bin /cygdrive/c/Users/Andy/Desktop `
        /cygdrive/c/Users/Andy/Documents /cygdrive/c/Users/Andy/Downloads `
        /cygdrive/c/Users/Andy/Music /cygdrive/c/Users/Andy/Pictures `
        /cygdrive/c/Users/Andy/Videos/Movies `
        /cygdrive/c/Users/Andy/Videos/Sony_Vegas_Videos `
        /cygdrive/c/Users/Andy/Videos/miscvideos `
        /cygdrive/e/rbackup
}

<#
function MakeTeX($file) {
    $file = $file.Replace(".\","") # brute force
    bash -c "latexmk -quiet -xelatex $file"
    bash -c 'latexmk -c'
}
#>

# prompt
$host.PrivateData.ErrorForegroundColor = 'Green'
function prompt {
    $loc = (Get-Location).ToString()
    Write-Host -Object "$(Get-Date -Format 'HH:mm:ss') PS" `
        -ForegroundColor 'DarkGreen' -NoNewline
    Write-Host -Object " $loc>  " -NoNewline; "`b"
}

# Set-Location -Path $HOME
