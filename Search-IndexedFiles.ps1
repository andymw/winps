<#
.SYNOPSIS
Searches for files in the Windows Search database
.DESCRIPTION
Searches for files matching specified patterns in the Windows Search database
.PARAMETER Pattern
The patterns to match against
.PARAMETER Table
Return results in a data table instead of printing text
.EXAMPLE
Search-IndexedFiles *.m4v,*.mkv
#>
[CmdletBinding()]
param(
    [Parameter(Position=0,Mandatory=$true)][string[]]$Pattern,
    [Parameter()][switch]$Table
)

$Pattern = $Pattern -replace "\*", "%"
$query = "SELECT System.ItemName, System.FileName, System.ItemPathDisplay, System.Size
    FROM SystemIndex WHERE System.FileName LIKE '" + $Pattern[0] + "'"

for ($idx = 1; $idx -lt $Pattern.Length; $idx++) {
    $query += " OR System.FileName LIKE '" + $Pattern[$idx] + "'"
}

$conn = New-Object -ComObject ADODB.Connection
$rs = New-Object -ComObject ADODB.recordset
$conn.Open("Provider=Search.CollatorDSO;Extended Properties='Application=Windows';")

try {
    $rs.open($query, $conn)
    $rs.MoveFirst()
} catch {
    try {
        $conn.Close()
        $rs.Close()
    } catch {}
    Write-Output "No results returned"
    exit
}

if ($Table) {
    $tbl = New-Object System.Data.DataTable "Results"
    $tbl.Columns.Add((New-Object System.Data.DataColumn Filename,([string])))
    $tbl.Columns.Add((New-Object System.Data.DataColumn FileSize,([long])))
    $tbl.Columns.Add((New-Object System.Data.DataColumn FullPath,([string])))
}

while (!($rs.EOF)) {
    $dir = Split-Path $rs.Fields.Item("System.ItemPathDisplay").value
    if ($Table) {
        $row = $tbl.NewRow()
        $row.FileSize = $rs.Fields.Item("System.Size").value
        $row.Filename = $rs.Fields.Item("System.FileName").value
        $row.FullPath = $rs.Fields.Item("System.ItemPathDisplay").value
        $tbl.Rows.Add($row)
    } else {
        if ($oldDir -ne $dir) {
            Write-Output $dir
            $oldDir = $dir
        }
        Write-Output ( "`t" + $rs.Fields.Item("System.Size").value + `
            "`t" + $rs.Fields.Item("System.FileName").value )
    }
    $rs.MoveNext()
}

$rs.Close()
$conn.Close()
$rs = $null
$conn = $null
[gc]::Collect()

if ($Table) { return $tbl }
