<#
.SYNOPSIS
Runs a specified program in parallel for each object in an input array
.DESCRIPTION
Runs a specified executable program in parallel for each object in an input array
.PARAMETER Objects
The list of objects to process
.PARAMETER Program
The program to run for each input objects
.PARAMETER Arguments
The arguments to pass to the program, as a space-delimited string
    Use '$_' to refer to the current object from the input array
.PARAMETER NumParallel
Maximum number of processes to run at once (default = no. of cores on system)
    Set to 0 for unlimited number of parallel processes
.PARAMETER ShowWindows
Show a console window for each parallel process
.EXAMPLE
Start-Parallel (ls *.wav) flac '-8 $_'
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)][Object[]]$Objects,
    [Parameter(Mandatory=$true, Position=1)][String]$Program,
    [Parameter(Position=2)][String]$Arguments,
    [Parameter()][int]$NumParallel = (Get-ChildItem ENV:\NUMBER_OF_PROCESSORS).Value,
    [Parameter()][switch]$ShowWindows
)

$processes = New-Object System.Collections.ArrayList
$idx = 0

if ($NumParallel -lt 0) {
    Write-Error 'NumParallel parameter cannot be negative.'
} elseif ($NumParallel -eq 0) {
    $NumParallel = [Int32]::MaxValue
}

# process all input objects
while ($idx -lt $Objects.Length) {

    # start up to $NumParallel processes
    while ($processes.Count -lt $NumParallel -and $idx -lt $Objects.Length) {

        $object = $Objects[$idx++]
        $args = $Arguments.Replace('$_', "`"$object`"")

        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $Program
        $pinfo.WorkingDirectory = $pwd.ToString()
        $pinfo.Arguments = $args
        if (!$ShowWindows) {
            $pinfo.WindowStyle = 'Hidden'
        }

        $newprocess = New-Object System.Diagnostics.Process
        $newprocess.StartInfo = $pinfo
        $processes.Add($newprocess) | Out-Null
        $newprocess.Start() | Out-Null
        Write-Output ('PID ' + $newprocess.ID + ': ' + $Program + ' ' + $args)

    }

    # wait for one terminating process
    while ($processes.Count -eq $NumParallel -and $idx -lt $Objects.Length) {
        for ($j = 0; $j -lt $processes.Count; $j++) {
            $process = $processes[$j]
            if ($process.HasExited) {
                $processes.Remove($process)
                Write-Output ('PID ' + $process.ID + ': Exit code ' + $process.ExitCode)
                break
            }
        }
        Start-Sleep -Milliseconds 20
    }

}

# wait for last processes to terminate
foreach ($process in $processes) {
    $process.WaitForExit()
    Write-Output ('PID ' + $process.ID + ': Exit code ' + $process.ExitCode)
}
