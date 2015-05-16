<#
.SYNOPSIS
Batch moving/copying tool
.DESCRIPTION
Batch file/directory moving/copying tool captures files that match a regex
  and renames/moves/copies them to a new destination/filename pattern.
    Parameters: -Path path/filenameRegex
                -Dest newpath/replacementWithGroups
                -Copy copies files to destination pattern instead of moving
    Examples:
        Batch-Rename '..\sol\11-([0-9]{2}).pdf' '..\sol\mv11-$1.pdf'
        Batch-Rename '11-([0-9]{2}).pdf' 'mv11-$1.pdf'
.NOTES
Windows PowerShell 3.0 script
Powershell's regex "backslash" is the symbol "$"
.PARAMETER Path
Contains the regex that matches on filenames.
Any file that matches the regex will be selected to be renamed and moved.
May consist of a directory, followed by a filename regex.
Note: No need to specify the start/end of regex (i.e. "^" and "$")
.PARAMETER Destination
Contains the regex for the files' destination.
May consist of a directory, followed by a filename regex.
Note: Powershell's regex "backslash" is the symbol "$"
.PARAMETER Copy
Copies files to destination pattern instead of moving
Note: performs a recursive copy of directories.
.PARAMETER Force
Force a file to be overwritten if a move/copy would result in an overwrite
.EXAMPLE
Batch-Rename -cp '..\sol\11-([0-9]{2}).pdf' '..\sol\mv11-$1.pdf'
Copies all files in the directory '..\sol\' that match "11-([0-9]{2}).pdf"
  to the directory '..\sol' with new name 'mv11-$1.pdf'
  (where $1 is the first group)
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Position=0,Mandatory=$True)][Alias("Source")][string]$Path,
    [Parameter(Position=1,Mandatory=$True)][string]$Destination,
    [Parameter()][Alias("c","cp")][switch]$Copy,
    [Parameter()][Alias("f")][switch]$Force,
    [Parameter()][switch]$help
)

Write-Output "`nTODO: Batch-Rename needs to support backslashes in regexes`n"

if ($help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

$dir = Split-Path $Path, $Destination
$ptn = Split-Path $Path, $Destination -Leaf
if ($dir[0].Length -eq 0) { $dir[0] = '.' }
if ($dir[1].Length -eq 0) { $dir[1] = '.' }

$files = Get-ChildItem -Path $dir[0] `
    | Where-Object {$_.Name -match ('^' + $ptn[0] + '$')}

if ($Copy) {
    $command = "Copy-Item"; Write-Output "`nBatch copying . . ."
} else {
    $command = "Move-Item"; Write-Output "`nBatch moving . . ."
}
if ($Force) {
    $command += " -Force"
}

$nidx = 0
foreach ($file in $files) {
    try { $newname = $file.Name -replace $ptn }
    catch { Write-Error "Invalid regular expression '$($ptn[0])'"; exit }
	$filename = $file.Name.Replace('[','`[').Replace(']','`]')
	$dest = $newname.Replace('[','`[').Replace(']','`]')
    if ($PSCmdlet.ShouldProcess("$($file.Name) -> $newname",$command)) {
        if ($Copy) {
            if ($Force) {
                Copy-Item -Force -Recurse -Path (Join-Path $dir[0] $filename) `
                    -Destination (Join-Path $dir[1] $dest) -ErrorAction Stop
            } else {
                Copy-Item -Recurse -Path (Join-Path $dir[0] $filename) `
                    -Destination (Join-Path $dir[1] $dest) -ErrorAction Stop
            }
        } else {
            if ($Force) {
                Move-Item -Force -Path (Join-Path $dir[0] $filename) `
                    -Destination (Join-Path $dir[1] $dest) -ErrorAction Stop
            } else {
                Move-Item -Path (Join-Path $dir[0] $filename) `
                    -Destination (Join-Path $dir[1] $dest) -ErrorAction Stop
            }
        }
        $nidx++
    } else { $nidx = -1 }
}

if ($nidx -eq -1) { Write-Output '' } else {
    Write-Output "`n$nidx files processed.`n"
}
