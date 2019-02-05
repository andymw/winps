<#
.SYNOPSIS
Function to Delete Windows System Restore points
.DESCRIPTION
Deletes Windows System Restore point(s) passed as an argument or via pipeline
.PARAMETER restorePoints
Restore point(s) to be deleted
(retrieved and optionally filtered from Get-ComputerRestorePoint
.EXAMPLE
#use -WhatIf to see what would have happened
Get-ComputerRestorePoint | Delete-ComputerRestorePoints -WhatIf
.EXAMPLE
#delete all System Restore Points older than 14 days
$removeDate = (Get-Date).AddDays(-14)
Get-ComputerRestorePoint |
    Where { $_.ConvertToDateTime($_.CreationTime) -lt  $removeDate } |
    Delete-ComputerRestorePoints
.LINK
http://gallery.technet.microsoft.com/scriptcenter/Script-to-delete-System-4960775a
#>
[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [Parameter(
        Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true
    )]
    $restorePoints
)

begin {
    $fullName="SystemRestore.DeleteRestorePoint"
    # check if the type is already loaded
    $isLoaded = ([AppDomain]::CurrentDomain.GetAssemblies() `
        | foreach {$_.GetTypes()} | where {$_.FullName -eq $fullName}) -ne $null
    if (!$isLoaded) {
        $SRClient = Add-Type -memberDefinition @"
            [DllImport ("Srclient.dll")]
            public static extern int SRRemoveRestorePoint (int index);
"@  -Name DeleteRestorePoint -NameSpace SystemRestore -PassThru
    }
}
process {
    foreach ($restorePoint in $restorePoints){
        if ($PSCmdlet.ShouldProcess("$($restorePoint.Description)",
                "Deleting Restorepoint")) {
            [SystemRestore.DeleteRestorePoint]::SRRemoveRestorePoint(
                $restorePoint.SequenceNumber
            )
        }
    }
}
