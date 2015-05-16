<#
.SYNOPSIS
Gets the utilization (free space, capacity, etc.) of mounted drives
.DESCRIPTION
Get-DriveUtilization.ps1: Gets the utilization of mounted drives
    Returns drive name, used space, free space, percent used, and capacity
.PARAMETER Name
The name of the drive to get utilization for (default: all drives)
.PARAMETER Table
Return data as a structured table
.EXAMPLE
Get-DriveUtilization C
Get-DriveUtilization -t
#>
[CmdletBinding()]
param (
    [Parameter(Position=0,ValueFromPipeline=$true)]
        [Object[]]$Drive=@('*'),
    [Parameter()][switch]$Table
)

begin {
    # Set up table
    if ($Table) {
        $outputTable = New-Object System.Data.DataTable "Drive Utilization"
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Name,([string])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Used,([long])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Free,([long])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Ratio,([double])))
        $outputTable.Columns.Add((New-Object System.Data.DataColumn Capacity,([long])))
    }
}
process {
    if ($Drive.Name) {
        $drives = $Drive | Where-Object Free
    } else {
        $drives = Get-PSDrive -Name $Drive | Where-Object Free
    }

    foreach ($drive in $drives) {
        $capacity = $drive.Used + $drive.Free
        $ratio = $drive.Used / $capacity
        if ($Table) {
            $row = $outputTable.NewRow()
            $row.Name     = $drive.Name
            $row.Used     = [long]$drive.Used
            $row.Free     = [long]$drive.Free
            $row.Ratio    = $ratio
            $row.Capacity = [long]$capacity
            $outputTable.Rows.Add($row)
        } else {
            Write-Output ("`nDrive " + $drive.Name)
            Write-Output (("{0:N2}" -f ($capacity / 1GB)) + ' GB capacity')
            Write-Output (("{0:N2}" -f ($drive.Used / 1GB)) + ' GB used')
            Write-Output (("{0:N2}" -f ($drive.Free / 1GB)) + ' GB free')
            Write-Output (("{0:N2}" -f ($ratio * 100)) + " percent used`n")
        }
    }
}
end {
    if ($Table) { return $outputTable }
}
