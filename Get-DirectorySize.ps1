<#
.SYNOPSIS
Gets size of a directory.
.DESCRIPTION
Get-DirSize.ps1: Prints the cumulative size of all files
    in the given directory and its subdirectories.
.PARAMETER Path
The directory(ies) to measure (default: current directory)
    Can be accepted via pipeline
.PARAMETER Table
Return data as a Powershell table instead of printing text
.PARAMETER NoRecurse
Gets the size and number of directories at depth=0.
.PARAMETER Filter
Applies specified filter to the directory's contents
.NOTES
Windows PowerShell 3.0 script
Written by Drew Weymouth and Andy Wang
February 2013
.EXAMPLE
Get-DirSize C:\Users\Foo\Desktop
Size of directory by path
.EXAMPLE
Get-DirSize -t .\foodir | epcsv foo.csv
Size of directory exported to CSV
.EXAMPLE
Get-DirSize -f -n *.txt
Size of .txt files in current directory (not subdirs)
#>

[CmdletBinding()]
param (
    [Parameter(Position=0, ValueFromPipeline=$true)][object[]]$Path=@('.'),
    [Parameter()][switch]$Table,
    [Parameter()][switch]$NoRecurse,
    [Parameter()][string]$Filter='',
    [Parameter()][switch]$help
)

begin {
    function Get-SizeStr([long]$size) {
        if (!$size) { $bytes = 0 } else { $bytes = "{0:N0}" -f $size }
        if ($size -lt 1MB) {
            return ("{0:N2}" -f ($size / 1KB) + " KB ($bytes bytes)")
        } elseif ($size -lt 1GB) {
            return ("{0:N2}" -f ($size / 1MB) + " MB ($bytes bytes)")
        } else {
            return ("{0:N2}" -f ($size / 1GB) + " GB ($bytes bytes)")
        }
    }

    if ($help) {
        Get-Help $MyInvocation.MyCommand.path; exit
    }

    # Set up table
    if ($Table) {
        $outputTable = New-Object System.Data.DataTable "Directory Size"
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Location,([string])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Size,([long])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn SizeOnDisk,([long])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Filter,([string])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Directories,([int])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Files,([int])))
    }

    $oldEAP = $ErrorActionPreference
}
process {
    foreach ($dir in $Path) {
        $ErrorActionPreference = $oldEAP
        if ($dir.FullName) { $dir = $dir.FullName }
        if ($dir.Contains('*')) {
            Write-Error ("Wildcards cannot appear in path`n" `
                + "    (use -Filter to specify a filter)")
            exit
        }
        try {
            $dir = (Resolve-Path $dir -ErrorAction Stop).Path
        } catch {
            Write-Error "Could not resolve path `"$dir`""; exit
        }

        $ErrorActionPreference = 'SilentlyContinue'

        # Get data
        if ($NoRecurse) {
            $contents = Get-ChildItem -Path $dir -Force -Filter $Filter
        } else {
            $contents = Get-ChildItem -Path $dir -Force -Recurse -Filter $Filter
        }
        $isFile = ($contents.Mode[0] -eq '-' -and !$Filter)
        $clusterSize = (Get-WmiObject Win32_Volume | `
            Where-Object {$_.DriveLetter -match $dir[0] }).BlockSize

        $numDir = 0; $numFiles = 0; $size = [long]0; $sizeOnDisk = [long]0
        foreach ($item in $contents) {
            if ($item.Mode[0] -eq 'd') {
                $numDir++
            } else {
                $length = ($item | Measure-Object -Property Length -Sum).Sum
                $size += $length
                $sizeOnDisk += [long]($clusterSize * `
                    [Math]::Ceiling($length / $clusterSize))
                $numFiles++
            }
        }

        # Format/Print data
        if ($Table) {
            $row = $outputTable.NewRow()
            $row.Location     = $dir
            $row.Size         = $size
            $row.SizeOnDisk   = $sizeOnDisk
            $row.Filter       = $Filter
            $row.Directories  = $numDir
            $row.Files        = $numFiles
            $outputTable.Rows.Add($row)
        } else {
            Write-Output "`n    Location:  $dir"
            if ($Filter) {
                Write-Output "      Filter:  $Filter"
            }
            Write-Output ("        Size:  " + (Get-SizeStr $size))
            if ($sizeOnDisk -ge 0) {
                Write-Output ("Size On Disk:  " + (Get-SizeStr $sizeOnDisk))
            }
            $fcount = "{0:N0}" -f $numFiles
            $dcount = "{0:N0}" -f $numDir
            if (!$isFile) {
                Write-Output "    Contains:  $fcount files, $dcount directories"
            }
            Write-Output ''
        }
    }
}
end {
    if ($Table) { return $outputTable }
}
