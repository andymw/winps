<#
.SYNOPSIS
String shortener (designed for directory paths)
.DESCRIPTION
String shortener takes in a string and shortens it based on a delimiter.
Designed primarily to be used with directory paths.
String will always contain the first and last components of the split.
    Parameters: -String   string
                -Number   threshold (int)
                -Delim    delimiter (string)
                -Fill     "fill" (string)

The string and threshold are positional parameters.
Delimiter and Fill must be specified with their parameter names.
.NOTES
Windows PowerShell 3.0 script
Written by Drew Weymouth and Andy Wang
February 2013
.PARAMETER String
The input string to be shortened if necessary
.PARAMETER Number
String shortening threshold (default 64, min 0, max 256)
Strings of length longer than n are shortened.
.PARAMETER Delimiter
The delimiter to partition the string (default: \)
.PARAMETER Fill
The truncated section of the string is replaced with this (default: ...)
.EXAMPLE
Shorten-Str 'this is a kinda long string' 9 -Delim ' ' -Fill 'WHOA'
   returns 'this WHOA string'
.EXAMPLE
Shorten-Str 'C:\Program Files\Microsoft SQL Server Compact Edition\v3.5' 50
   returns 'C:\...\Microsoft SQL Server Compact Edition\v3.5'
#>

[CmdletBinding()]
[OutputType([System.String])]
param (
    [Parameter(Position=0)][string]$String,
    [Parameter(Position=1)][ValidateRange(0,256)][Alias("threshold")]
        [int]$Number = 64,
    [Parameter()][string]$Delimiter = '\',
    [Parameter()][string]$Fill = '...',
    [switch]$help
)

if ($help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

$parts = $String.Split($Delimiter)
if ($String.Length -lt $Number -or $parts.Length -lt 3) {
    return $String
}

# take first directory in path
$begin = $parts[0] + $Delimiter

# take last directory in path
$end = $Delimiter + $parts[$parts.Length - 1]

# take as many others as possible, working backwards from last
for ($i = $parts.Length - 2; $i -gt 0 -and $end.Length +
        $begin.Length + $parts[$i].Length -lt $Number; $i--) {
    $end = $Delimiter + $parts[$i] + $end
}

$shortened = $begin + $Fill + $end
if ($String.Length -gt $shortened.Length) {
    return $shortened
} else {
    return $String
}
