<#
.SYNOPSIS
kills processes
.DESCRIPTION
Kills (or force-kills -f) processes and optionally restarts them (-r)
.PARAMETER force
Performs a force kill (Stop-Process)
.PARAMETER restart
Optional switch to restart process
.EXAMPLE
Kill-Process chrome

This gracefully stops all chrome.exe processes.
.EXAMPLE
Kill-Process -r -f notepad++

This force-kills the process notepad++.exe and restarts it.
.NOTES
Windows PowerShell 3.0 script written by Drew Weymouth
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$True)][string[]]$procs,
    [switch]$force,
    [switch]$restart
)

process {
    foreach ($proc in $procs) {
        if ($proc.EndsWith('.exe')) { $proc = $proc.TrimEnd('.exe') }
        $process = (Get-Process -ErrorAction SilentlyContinue $proc)
        if ($process -eq $null) {
            Write-Output "Warning: process ""$proc"" not found."; continue
        }
        if ($restart) {
            try {
                $id = $process.ID
                $cmdline = Get-WMIObject Win32_Process `
                    -Filter "Handle=$id" -ErrorAction Stop
            } catch {
                Write-Error 'Wildcards are not supported for restarts'; exit
            }
            $cmdline = $cmdline.CommandLine
            $cmdline = `
                $cmdline.Substring(0, $cmdline.LastIndexOf('.exe')+4) + """"
        }

        $pnames = ($process | foreach {$_.ProcessName + ";"}) + "`b"
        if ($force) {
            if ($PSCmdlet.ShouldProcess($pnames, "Kill-Process")) {
                Stop-Process $process
            }
        } else {
            if ($PSCmdlet.ShouldProcess($pnames, "Kill-Process")) {
                $process.CloseMainWindow() | Out-Null
            }
        }
        if ($restart) {
            $process.WaitForExit()
            Start-Process "$cmdline"
        }
    }
}
