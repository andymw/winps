<#
.SYNOPSIS
Plays a specified wav file
.DESCRIPTION
Asynchronously plays a specified wav file
.PARAMETER Stop
Stops the currently playing file
.PARAMETER WavFile
Plays the specified file
.EXAMPLE
Play-WavFile .\01_Bamboleo.wav
Play-WavFile -Stop
#>
[CmdletBinding()]
param (
    [Parameter(Position=0)][string]$WavFile,
    [Parameter()][switch]$Stop
)

if ($Stop) {
    (New-Object System.Media.SoundPlayer).Stop()
} else {
    (New-Object System.Media.SoundPlayer (Resolve-Path $WavFile)).Play()
}
