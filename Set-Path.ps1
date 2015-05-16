<#
.SYNOPSIS
Performs operations on PATH
.DESCRIPTION
Prints, appends to, and removes from the PATH environment variable ($env:Path).
    Switches:   -Text     Prints PATH as text
                -Numbers  Prints PATH with line numbers
                          (ensures no formatting in "table mode")
    Operations: -Get index
                -Add dir(,index)
                -MoveTo [dir|index],index
                -Remove [dir|index]
                -Export [filepath]
                -Import [filepath]
                -SetFromFile [filepath]
                -Cleanup

If path encounters a switch: prints PATH as specified and no operations
  (add, remove, etc.) get performed.
When given more than one non-switch parameter, only the first action in
  this order of precedence is performed:
    GET -> ADD -> MOVETO -> REMOVE -> EXPORT -> IMPORT -> SETFROMFILE -> CLEANUP
.NOTES
Windows PowerShell 3.0 script
Written by Andy Wang, Drew Weymouth
February 2013
.PARAMETER Get
Returns the directory on the path at specified index.
.PARAMETER Add
Adds the following directory to the path at a given position.
If given only a directory, appends it to the end of the path.
.PARAMETER MoveTo
Moves a directory given by either its absolute path or index to another index.
.PARAMETER Remove
Removes a directory given either an index or the absolute directory path
.PARAMETER Export
Exports PATH to the specified file
.PARAMETER Import
Adds directories from the specified file to the path
.PARAMETER SetFromFile
Sets the PATH environment file to contain the directories in the specified file
.PARAMETER Cleanup
Removes nonexistent and redundant directories from the path.
.PARAMETER Text
Prints the PATH environment variable as text
.PARAMETER Numbers
Prints line numbers along with the PATH environment variable
Special case: when used alone (i.e. path -n, without -text),
  performs no formatting: output type is System.Data.DataRow
  (can be piped, i.e. export-csv)
.EXAMPLE
path
Returns the contents of the PATH environment variable as a formatted table.
.EXAMPLE
path -t -n
path -text -numbers
Returns and numbers the contents of the PATH environment variable as text.
.EXAMPLE
path -n | Export-Csv 'C:\path.csv'
Exports the contents of the PATH variable as a CSV file to path.csv
.EXAMPLE
(path -n)[3]
Find the directory in the PATH at index 3.
.EXAMPLE
path -Add dir(,index)
path -MoveTo [dir|index],index
path -Remove [dir|index]
path -Export [filepath]
path -Import [filepath]
path -SetFromFile [filepath]
path -Cleanup
#>
[CmdletBinding(SupportsShouldProcess=$true)]
[OutputType([System.Data.DataRow],[System.String])]
param (
    [Parameter(Position=0)][int]$Get=(-1),
    [Parameter(Position=0)][ValidateCount(1,2)][string[]]$Add,
    [Parameter(Position=0)][ValidateCount(2,2)][Alias("mv")][string[]]$MoveTo,
    [Parameter(Position=0)][Alias("rm")][string]$Remove,
    [Parameter(Position=0)][Alias("x")][string]$Export,
    [Parameter(Position=0)][string]$Import,
    [Parameter(Position=0)][string]$SetFromFile,
    [Parameter()][Alias("c")][switch]$Cleanup,
    [Parameter()][switch]$Text,
    [Parameter()][switch]$Numbers,
    [Parameter()][switch]$Help
)

#### FUNCTION DEFINITIONS ###

function Write-PathTable ([string[]]$path, [bool]$noformat) {
    $pathtable = New-Object System.Data.DataTable "Path"
    $idx = New-Object System.Data.DataColumn Index,([string])
    $dir = New-Object System.Data.DataColumn Directory,([string])
    $pathtable.Columns.Add($idx)
    $pathtable.Columns.Add($dir)

    foreach ($elem in $path) {
        $row = $pathtable.NewRow()
        $row.Index = $pathtable.Rows.Count
        $row.Directory = $elem
        $pathtable.Rows.Add($row)
    }
    if ($noformat) {
        Write-Output $pathtable
    } else {
        Write-Output $pathtable | Format-Table -AutoSize
    }
}

function Write-PathString ([string[]]$path, [bool]$Numbers) {
    # Write-Output ''
    if ($Numbers) { # add line numbers
        for ($i = 0; $i -lt ([string[]]$path).Length; $i++) {
            $elem = $path[$i]
            Write-Output "$i`t$elem"
        }
    } else { Write-Output $path }
    # Write-Output ''
}

function Add ([string[]]$path, [int]$idx, [string]$toAdd) {
    $toAdd = $toAdd.TrimEnd('\') + '\'
    if (([string[]]$path).Length -eq 0) {
        $path = @($toAdd)
    } elseif ($idx -eq 0) {
        $path = @($toAdd) + $path
    } elseif ($idx -eq ([string[]]$path).Length) {
        $path = $path + @($toAdd)
    } elseif ($idx -lt ([string[]]$path).Length -and $idx -gt 0) {
        $path = $path[0..($idx-1)] + @($toAdd) `
            + $path[$idx..(([string[]]$path).Length-1)]
    } else {
        Write-Error 'Index out of bounds'; break
    }
    return $path
}

function Remove ([string[]]$path, [int]$idx) {
    $len = ([string[]]$path).Length
    if ($idx -eq 0) {
        $path = $path[1..($len-1)]
    } elseif ($idx -eq ($len-1)) {
        $path = $path[0..($len-2)]
    } elseif ($idx -lt ($len-1) -and $idx -gt 0) {
        $path = $path[0..($idx-1)] + $path[($idx+1)..($len-1)]
    } else {
        Write-Error 'Index out of bounds'; break
    }
    return $path
}

function Cleanup ([string[]]$path) {
    for ($idx,$len = 0,([string[]]$path).Length; $idx -lt $len; ) {
        if (($idx -gt 0 -and $path[0..($idx-1)].Contains($path[$idx])) -or
                !(Test-Path $path[$idx])) {
            $path = Remove $path $idx; $len--
        } else { $idx++ }
    }
    return $path
}

function IndexOf ([string[]]$path, [string]$item) {
    $item = $item.TrimEnd('\') + '\'
    $idx = [array]::IndexOf($path, $item)
    if ($idx -eq -1) {
        Write-Error "Specified directory not found in path"; break
    }
    return $idx
}

########  OPERATIONS BEGIN HERE  ########

if ($Help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

try {
    $old_path = [System.Environment]::GetEnvironmentVariable(
        "PATH", [System.EnvironmentVariableTarget]::Machine
    ).Split(';')
} catch {
    Write-Warning "No system path variable found."
}

for ($i = 0; $i -lt ([string[]]$old_path).Length; $i++) {
    $old_path[$i] = $old_path[$i].TrimEnd('\') + '\'
}
$orig_path = $old_path # make a copy

if ($Text) { # print PATH as string[]
    Write-PathString $old_path $Numbers; exit
}
elseif ($Get -ne -1) {
    if ($Get -lt 0 -or $Get -gt ([string[]]$old_path).Length - 1) {
        Write-Error "Index out of bounds."; exit
    }
    Write-Output $old_path[$Get]; exit
}
elseif ($Add) {
    $resolved = Resolve-Path $Add[0] -ErrorAction Stop
    $dir = $resolved.ToString().TrimEnd('\') + '\'
    if ($old_path -contains $dir) {
        Write-Error 'Directory already exists on Path'; exit
    }
    if ($Add.Length -eq 2) { $idx = $Add[1] }
    else { $idx = ([string[]]$old_path).Length }
    if ($PSCmdlet.ShouldProcess("PATH","Add $dir on PATH at index $idx")) {
        $old_path = Add $old_path $idx $dir
    }
}
elseif ($MoveTo) {
    $to = [int]$MoveTo[1]
    try { $from = [int]$MoveTo[0] }
    catch {
        $resolved = Resolve-Path $MoveTo[0] -ErrorAction Stop
        $from = IndexOf $old_path $resolved
    }
    $dir = $old_path[$from]
    #if (!$dir) { Write-Error 'Index out of bounds'; break }
    if ($PSCmdlet.ShouldProcess("PATH","Move $dir on PATH to index $to")) {
        $old_path = Remove $old_path $from
        $old_path = Add $old_path $to $dir
    }
}
elseif ($Remove) {
    try { $remidx = [int]$Remove }
    catch {
        $resolved = Resolve-Path $Remove -ErrorAction Stop
        $remidx = IndexOf $old_path $resolved
    }
    $dir = $old_path[$remidx]
    if (!$dir) { Write-Error 'Index out of bounds'; break }
    if ($PSCmdlet.ShouldProcess("PATH","Remove $dir at index $remidx")) {
        $old_path = Remove $old_path $remidx
    }
}
elseif ($Export) {
    if ($PSCmdlet.ShouldProcess("PATH","Write PATH to $Export")) {
        Set-Content $Export (Write-PathString $old_path $false)
    }
}
elseif ($Import) {
    if ($PSCmdlet.ShouldProcess("PATH","Import directories from $Import")) {
        foreach ($line in (Get-Content -ReadCount 0 $Import)) {
            foreach ($dir in ($line.Split(";"))) {
                try {
                    Resolve-Path $dir -ErrorAction Stop | Out-Null
                } catch {
                    Write-Error "Directory $dir does not exist"; exit
                }
                $old_path = Add $old_path (([string[]]$old_path).Length) $dir
            }
        }
        $old_path = Cleanup $old_path
    }
}
elseif ($SetFromFile) {
    if ($PSCmdlet.ShouldProcess("PATH", "Set path from $SetFromFile")) {
        $old_path = [string[]]$null
        foreach ($line in (Get-Content -ReadCount 0 $SetFromFile)) {
            foreach ($dir in ($line.Split(";"))) {
                try {
                    Resolve-Path $dir -ErrorAction Stop | Out-Null
                } catch {
                    Write-Error "Directory $dir does not exist"; exit
                }
                $old_path = Add $old_path (([string[]]$old_path).Length) $dir
            }
        }
    }
}
elseif ($Cleanup) {
    if ($PSCmdlet.ShouldProcess("PATH",
            "Cleanup nonexistent and redundant directories")) {
        $old_path = Cleanup $old_path
    }
}
else {
    Write-PathTable $old_path $Numbers #print PATH as table
    exit
}

#### CHANGE PATH ####

if ($old_path -and $old_path.Equals($orig_path)) { # whatif, confirm, unmodified
    Write-Output "PATH unchanged.`n"; exit
}
# make new path string
$new_path = $null
foreach ($elem in $old_path) {
    $new_path += $elem + ';'
}
if ($new_path) { $new_path = $new_path.TrimEnd(';') }
else { Write-Warning "PATH set to null." }

# set new PATH
[System.Environment]::SetEnvironmentVariable(
    "PATH", $new_path, [System.EnvironmentVariableTarget]::Machine
)
$env:PATH = $new_path # for current PowerShell session

Write-Output "PATH changed successfully.`n"
