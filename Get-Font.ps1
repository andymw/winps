<#
.SYNOPSIS
View fonts installed on the computer
.DESCRIPTION
View fonts installed on the computer either on the console
    or in a graphical Internet Explorer window
.PARAMETER Name
Include fonts matching this name pattern only
.PARAMETER Exact
Include only fonts matching the exact Name pattern
.PARAMETER Console
Include only fonts that are installed as console fonts
.PARAMETER Graphical
Show fonts graphically in Internet Explorer
.PARAMETER Text
When used with Graphical - set the text to display in each font
.PARAMETER Size
When used with Graphical - set the HTML font size for displayed fonts
.EXAMPLE
Get-Font Arial -Graphical -Text 'Hello world!'
Show all Arial fonts (Arial Black, Arial Narrow, etc.) in a graphical
    window displaying the text Hello world!
#>
[CmdletBinding()]
param (
    [Parameter(Position=0)][string]$Name = '.',
    [Parameter()][switch]$Console,
    [Parameter()][Alias("e")][switch]$Exact,
    [Parameter()][switch]$Graphical,
    [Parameter()][string]$Text,
    [Parameter()][int]$Size = 5
)

if ($Exact) {
    $Name = '^' + $Name + '$'
}

if ($Console) {
    $key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont"
    $fonts = (Get-ItemProperty $key | Get-Member | `
        Where-Object { $_.Name -match "^0+$" } | `
        Where-Object { $_.Definition -match $Name }).Definition | `
        Foreach-Object { if ($_) { $_.Substring($_.IndexOf('=') + 1) } }
} else {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $fonts = ( (New-Object System.Drawing.Text.InstalledFontCollection).Families `
        | Where-Object {$_.Name -match $Name } ).Name
}

if (!$Graphical) { return $fonts }

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class SFW {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@

$objIE = New-Object -com "InternetExplorer.Application"
$objIE.Navigate("about:blank")
$objIE.ToolBar = 0; $objIE.StatusBar = 0
$objIE.Width = 500

$objDoc = $objIE.Document.DocumentElement.LastChild

$strHTML = ''
foreach ($font in $fonts) {
    if ($Text) { $show = $Text }
    else { $show = $font }

    $strHTML = $strHTML + "<font size='$size' face='" + `
        $font + "'>" + $show + "</font><br>"
}

$objDoc.InnerHTML = $strHTML
$objIE.Visible = $True
$h = (Get-Process iexplore).MainWindowHandle
foreach ($h0 in $h) {
    [SFW]::SetForegroundWindow($h0) | Out-Null
}
