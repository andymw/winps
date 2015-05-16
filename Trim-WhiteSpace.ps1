<#
.SYNOPSIS
Trims whitespace from ends of lines given text file(s)
.DESCRIPTION
Trim-WhiteSpace trims whitespace (spaces and tabs) from the end of lines of
  text file(s). Also converts UNIX-type LF line delimiters to Windows CR+LF
WARNING: Do not use on binary files!
.NOTES
Written by Drew Weymouth, Andy Wang
February 2013
.EXAMPLE
Trim-WhiteSpace *.txt
trims all text files in the current directory
.EXAMPLE
Get-ChildItem -r *.txt | Trim-WhiteSpace
trims all text files in the current directory and subdirectories
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)][Object[]]$Path
)

begin {
}
process {
    foreach ($fileset in $Path) {
        if ($fileset.FullName) { $fileset = $fileset.FullName }
        try {
            $files = Get-ChildItem $fileset -ErrorAction Stop `
                | Where-Object {!$_.PsIsContainer} | foreach { $_.FullName }
        } catch {
            Write-Error "Could not resolve path `"$fileset`""; exit
        }
        foreach ($file in $files) {
            if ($PSCmdlet.ShouldProcess($file)) {
                ((Get-Content $file -ReadCount 0) -Replace "[ \t]+$","") `
                    | Set-Content $file
            }
        }
    }
}
end {
}

