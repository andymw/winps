<#
.SYNOPSIS
Removes "temporary" files.
.DESCRIPTION
Removes all 'desktop.ini', 'thumbs.db', and (optionally) tmp and temp files
    from given directory/directories.
.EXAMPLE
Clean-TemporaryFiles
Removes all 'desktop.ini' and 'thumbs.db' files in user's home directory.
.EXAMPLE
Clean-TemporaryFiles -Path 'D:\','E:\' -Tmp -WhatIf
Lists the desktop.ini, thumbs.db, tmp, and temp on drives D and E to be deleted.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(ValueFromPipeline=$true)][string[]]$Path = $HOME,
    [Parameter()][switch]$Tmp
)

begin {
    $count = 0
}
process {
    foreach ($p in [string[]]$Path) {
        $desktopini = Get-ChildItem -Recurse `
            -Path $p -Filter 'desktop.ini' -Force -ErrorAction SilentlyContinue

        foreach ($item in $desktopini) {
            if ($PSCmdlet.ShouldProcess($item.FullName,"Remove-Item")) {
                Remove-Item -Path $item.FullName `
                    -Force -ErrorAction SilentlyContinue
                $count++
            }
        }

        $thumbsdb = Get-ChildItem -Recurse `
            -Path $p -Filter 'thumbs.db' -Force -ErrorAction SilentlyContinue

        foreach ($item in $thumbsdb) {
            if ($PSCmdlet.ShouldProcess($item.FullName,"Remove-Item")) {
                Remove-Item -Path $item.FullName `
                    -Force -ErrorAction SilentlyContinue
                $count++
            }
        }

        if ($tmp) {
            $alltmp = Get-ChildItem -Recurse `
                -Path $p -Filter '*.tmp' -Force -ErrorAction SilentlyContinue
            $alltmp += Get-ChildItem -Recurse `
                -Path $p -Filter '*.temp' -Force -ErrorAction SilentlyContinue

            foreach ($item in $alltmp) {
                if ($PSCmdlet.ShouldProcess($item.FullName,"Remove-Item")) {
                    Remove-Item -Path $item.FullName `
                        -Force -ErrorAction SilentlyContinue
                $count++
                }
            }
        }
    }
}
end {
    if ($count) {
        Write-Output "Attempted to remove $count temporary files."
    }
}
