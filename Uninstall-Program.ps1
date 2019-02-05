<#
.SYNOPSIS
Uninstalls installed programs
.DESCRIPTION
Uninstall-Program.ps1 - runs programs' associated uninstallers
  Programs may be passed as an argument or via pipeline
.PARAMETER Programs
Programs to be uninstalled (received from Get-Program.ps1)
.EXAMPLE
Get-Program firefox | Uninstall-Program
Uninstalls Mozilla Firefox
.EXAMPLE
Get-Program -Publisher Piriform | Uninstall-Program
Uninstalls all programs published by Piriform
.EXAMPLE
Get-Program | Uninstall-Program -WhatIf
Simulates uninstalling all programs
.SEE
Get-Program.ps1
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Position=0, ValueFromPipeline=$true)][Object[]]$Programs,
    [Parameter()][switch]$Help
)

begin {
    if ($Help) {
        Get-Help $MyInvocation.MyCommand.path; exit
    }
    function Format-UninstallString ([string]$uninst) {
        # MsiExec.exe /I{AC456-Blah-blah} -> MsiExec.exe "/I{AC456-Blah-blah}"
        if ($uninst.StartsWith("MsiExec.exe")) {
            return ('MsiExec.exe ' + '"' + `
                $uninst.Substring($uninst.IndexOf('/')) + '"')
        }

        # blah.exe foo bar -> "blah.exe" foo bar
        if (!$uninst.StartsWith('"') -and $uninst.Contains('.exe')) {
            $idx = $uninst.IndexOf('.exe') + 4;
            $uninst = `
                '"' + $uninst.Substring(0, $idx) + '"' + $uninst.Substring($idx)
        }
        return $uninst
    }
}

process {
    if (!$Programs.UninstallString) {
        Write-Output 'Use Get-Program to get programs to uninstall'; exit
    }
    foreach ($program in $Programs) {
        $uninst = Format-UninstallString $program.UninstallString
        if ($PSCmdlet.ShouldProcess(
                "$($program.DisplayName)","Uninstall Program")) {
            if ($program.InstallLocation) {
                $from = " from $($program.InstallLocation)"
            }
            Write-Output ("Uninstalling $($program.DisplayName)" + $from)
            try {
                Invoke-Expression "& $uninst"
            } catch {
                Write-Error "Unable to run uninstall string: $uninst"; exit
            }
        }
    }
}
