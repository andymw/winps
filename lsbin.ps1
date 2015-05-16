# performs a Get-ChildItem of the user's bin directory.
# assumes the location variable $bin is defined.
[CmdletBinding()]
param(
    [Parameter()][string]$Filter = '*',
    [Parameter()][switch]$All
)

# $Path = $bin
# Get-ChildItem $Path

$exts += @('.com','.exe','.cmd','.cpl','.ps1','.bat')
if ($All) {
    $exts += @('.dll','.jar','.sh')
}

# assertions, sanity checking
$exts = $exts | Select-Object -Unique
for ($i = 0; $i -lt $exts.Length; $i++) {
    $exts[$i] = Join-Path $bin "*$($exts[$i].ToLower())"
}

Get-ChildItem $exts -Filter $Filter
