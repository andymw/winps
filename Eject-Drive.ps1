<#
.Synopsis
Ejects mounted disk drives
.DESCRIPTION
Eject-Drive.ps1: Ejects drive specified by drive letter
.PARAMETER Drive
The drive letter of the drive to eject
.NOTES
Written by Drew Weymouth
February 2013
.EXAMPLE
Eject-Drive D
.EXAMPLE
Get-PSDrive | Where-Object {$_.Provider -match 'FileSystem'} | Eject-Drive
Ejects all "ejectable" filesystems (safely)
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [Object[]]$Drive
)

begin {
    $sa = New-Object -comObject Shell.Application
}
process {
    if (!$Drive.Name) {
        $Drive = Get-PSDrive $Drive
    }
    foreach ($dr in $Drive | Where-Object {$_.Provider -match 'FileSystem'}) {
        $dr = $dr.Name + ':'
        if ($PSCmdlet.ShouldProcess($dr,"Eject-Drive")) {
            try {
                $sa.NameSpace(17).ParseName($dr).InvokeVerb("Eject")
            } catch {
                Write-Error "Could not locate drive ""$dr"""
            }
        }
    }
}
