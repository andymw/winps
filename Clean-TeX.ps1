<#
.EXAMPLE
Clean-TeX
Cleans the current directory
.EXAMPLE
ls .\TeXProjects -r | Clean-TeX
Cleans all directories and subdirectories of .\TeXProjects
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(ValueFromPipeline=$true)][Object[]]$Path=@('.'),
    [Parameter()][switch]$Aux,
    [Parameter()][switch]$Bbl,
    [Parameter()][switch]$Bcf,
    [Parameter()][switch]$Blg,
    [Parameter()][switch]$Log,
    [Parameter()][switch]$Out,
    [Parameter()][switch]$Toc,
    [Parameter()][switch]$Xml,
    [Parameter()][switch]$Nav,
    [Parameter()][switch]$Snm
)
begin {
    $arr = @(('log',$Log),('aux',$Aux),('out',$Out),('toc',$Toc),('bbl',$Bbl), `
    ('bcf',$Bcf),('blg',$Blg),('run.xml',$Xml),('nav',$Nav),('snm',$Snm))
}
process {
    foreach ($dir in $Path) {
        if ($dir.FullName) { $dir = $dir.FullName }
        Resolve-Path -Path $dir -ErrorAction Stop | Out-Null

        foreach ($tpl in $arr) {
            if (!$tpl[1]) {
                $contents = Get-ChildItem -Path (Join-Path $dir "*.$($tpl[0])")
                foreach ($item in $contents) {
                    if ($PSCmdlet.ShouldProcess($item,"Remove-Item")) {
                        Remove-Item -Path $item
                    }
                }
            }
        }
    }
}
