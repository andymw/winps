<#
.SYNOPSIS
Returns a list of duplicate filenames on PATH directories
.DESCRIPTION
Returns a list of duplicate filenames on PATH directories
.NOTES
Windows PowerShell 3.0
.PARAMETER Filter
Filter - a globbing expression to filter results
.PARAMETER Text
Returns results in text (non-structured) format
#>
[CmdletBinding()]
param (
    [Parameter(Position=0)][string]$Filter = '*',
    [Parameter()][switch]$Text
)

$hashtbl = New-Object Hashtable

foreach ($dir in (Set-Path -n).Directory) {
    $filtered = Get-ChildItem -Path $dir -File -Filter $Filter -ErrorAction Stop
    foreach ($file in $filtered.Name) {
        if ($hashtbl.ContainsKey($file)) {
            $arr = $hashtbl.Get_Item($file)
            $hashtbl.Remove($file)
            $hashtbl.Add($file, ($arr + $dir))
        } else {
            $hashtbl.Add($file,@($dir))
        }
    }
}

if (!$Text) {
    $tbl = New-Object System.Data.DataTable "Duplicates"
    $name = New-Object System.Data.DataColumn Name,([string])
    $dirs = New-Object System.Data.DataColumn Directories,([string[]])
    $tbl.Columns.Add($name)
    $tbl.Columns.Add($dirs)
}

foreach ($key in ($hashtbl.Keys | Sort-Object)) {
    $arr = $hashtbl.Get_Item($key)
    if ($arr.Length -eq 1) { continue }
    if ($Text) {
        Write-Output $key
        foreach ($dir in $arr) {
            Write-Output "    $dir"
        }
    } else {
        $row = $tbl.NewRow()
        $row.Name = $key
        $row.Directories = [string[]]$hashtbl.Get_Item($key)
        $tbl.Rows.Add($row)
    }
}

if (!$Text) {
    return $tbl
}
