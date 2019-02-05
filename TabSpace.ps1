<#
.SYNOPSIS
Converts spaces and tabs at beginnings of lines of file(s)
.DESCRIPTION
TabSpace converts spaces to and from tabs at the beginnings of each line
  of each given file(s).
  Default configuration: converts tabs to spaces of 4 characters
  Also converts UNIX-type LF line delimiters to Windows CR+LF
  NOTE: assumes the Cygwin executables expand and unexpand exist
    Parameters: -Files      files
                -Spaces     convert tabs to spaces
                -Tabs       convert spaces to tabs
                -Width      set custom tab width (default 4, min 1, max 64)
                -Unix       write output file with LF (Unix) delimiters
  Cannot specify both tabs and spaces at the same time.
  WARNING: Do not use on binary files!
.NOTES
Windows PowerShell 3.0 script
Written by Andy Wang and Drew Weymouth
February 2013
.EXAMPLE
tabspace file.txt -t
Convert consecutive spaces in file.txt to tabs
.EXAMPLE
ls -r *.txt | tabspace -s
Expands tabs in all text files in the current directory and subdirectories
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)][Object[]]$Files,
    [Parameter()][switch]$Spaces,
    [Parameter()][switch]$Tabs,
    [Parameter()][Alias("w")][ValidateRange(1,64)][int]$Width=4,
    [Parameter()][switch]$Unix,
    [Parameter()][switch]$help
)

begin {
    if ($help) {
        Get-Help $MyInvocation.MyCommand.path; exit
    }
    if (($Tabs -and $Spaces) -or (!$Tabs -and !$Spaces)) {
        Write-Output ('Usage: TabSpace [-Files] <String[]> ' `
            + '[-Spaces] [-Tabs] [[-Width] <Int32>] [-Unix] [-help]')
        exit
    }

    if (!$cygbin) {
        Write-Warning '$cygbin not defined. Using "C:\Program Files\cygwin\bin"'
        $cygbin = 'C:\Program Files\cygwin\bin\'
    }

    try {
        $cygbin = (Resolve-Path $cygbin -ErrorAction Stop).Path
    } catch {
        Write-Error 'Could not locate Cygwin executables'; exit
    }
    if ($Spaces -and $Unix) {
        $command = "tabs to spaces (Unix)"
    } elseif ($Spaces) {
        $command = "tabs to spaces"
    } elseif ($Unix) {
        $command = "spaces to tabs (Unix)"
    } else {
        $command = "spaces to tabs"
    }
}
process {
    foreach ($fileset in $Files) {
        if ($fileset.FullName) { $fileset = $fileset.FullName }
        try {
            $fileset = Get-ChildItem $fileset -ErrorAction Stop `
                | Where-Object {!$_.PsIsContainer} | foreach { $_.FullName }
        } catch {
            Write-Error "Could not resolve path `"$fileset`""; exit
        }
        foreach ($file in $fileset) {
            if ($PSCmdlet.ShouldProcess("$file","$command")) {
                if ($Spaces) {
                    & (Join-Path $cygbin 'expand.exe') $file -t $Width `
                        | Set-Content $file
                } else {
                    & (Join-Path $cygbin 'unexpand.exe') $file -t $Width `
                        | Set-Content $file
                }
                if ($Unix) {
                    & (Join-Path $cygbin 'dos2unix.exe') $file
                }
            }
        }
    }
}
end {}
