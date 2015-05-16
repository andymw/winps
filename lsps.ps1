# performs a Get-ChildItem on the user's PowerShell directory
[CmdletBinding()]
param(
    [Parameter()][string]$Filter = '*',
    [Parameter()][switch]$All
)

$Path = Split-Path $PROFILE
# Get-ChildItem $Path

$exts += @('.ps1','.bat','.wsf','.wsh','.sh','.pl','.py')
if ($All) {
    $exts += @('.com','.exe','.cmd','.cpl','.dll','.jar')
}

# assertions, sanity checking
$exts = $exts | Select-Object -Unique
for ($i = 0; $i -lt $exts.Length; $i++) {
    $exts[$i] = Join-Path $Path "*$($exts[$i].ToLower())"
}

Get-ChildItem $exts -Filter $Filter
