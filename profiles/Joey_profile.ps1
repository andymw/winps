
function beep { Write-Output `a }
function computer { explorer '/root,' }
function rbin { Start-Process shell:recyclebinfolder }
function lc { ($input | Measure-Object).Count }

# mkdir with no text output
function mkdir([string[]]$dirs) {
    if (!$dirs) {
        New-Item -ItemType directory | Out-Null
    } else {
        New-Item -Path $dirs -ItemType directory | Out-Null
    }
}

function prompt {
    $loc = (Get-Location).ToString()
    if ($loc.StartsWith("$HOME\")) {
        $loc = $loc.Substring($HOME.Length + 1)
    }
    $loc = Shorten-String $loc 55
    Write-Host -ForegroundColor 'Green' -NoNewLine "PS $loc>  "; "`b"
}

# Application Launchers
New-Alias -Force audacity 'C:\Program Files (x86)\Audacity\audacity.exe'
New-Alias -Force ccleaner 'C:\Program Files\CCleaner\CCleaner64.exe'
New-Alias -Force chrome 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
New-Alias -Force defraggler 'C:\Program Files\Defraggler\Defraggler64.exe'
New-Alias -Force dvddecrypter 'C:\Program Files (x86)\DVD Decrypter\DVDDecrypter.exe'
New-Alias -Force excel 'C:\Program Files (x86)\Microsoft Office\Office12\EXCEL.exe'
New-Alias -Force foobar 'C:\Program Files (x86)\foobar2000\foobar2000.exe'
New-Alias -Force foobar2000 'C:\Program Files (x86)\foobar2000\foobar2000.exe'
New-Alias -Force handbrake 'C:\Program Files\Handbrake\Handbrake.exe'
New-Alias -Force iexplore 'C:\Program Files (x86)\Internet Explorer\iexplore.exe'
New-Alias -Force mse 'C:\Program Files\Microsoft Security Client\msseces.exe'
New-Alias -Force npp 'C:\Program Files (x86)\Notepad++\notepad++.exe'
New-Alias -Force powerpnt 'C:\Program Files (x86)\Microsoft Office\Office12\POWERPNT.exe'
New-Alias -Force powerpoint 'C:\Program Files (x86)\Microsoft Office\Office12\POWERPNT.exe'
New-Alias -Force publisher 'C:\Program Files (x86)\Microsoft Office\Office12\MSPUB.exe'
New-Alias -Force vlc 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe'
New-Alias -Force vstudio 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe'
New-Alias -Force word 'C:\Program Files (x86)\Microsoft Office\Office12\WINWORD.exe'
#Windows utils
New-Alias -Force paint mspaint
New-Alias -Force snip SnippingTool

. Load-ScriptAlias

#Locations
$desktop = 'C:\Users\Joey\Desktop'
$scripts = 'C:\Users\Joey\Documents\WindowsPowershell'
# $svnall = @($var1,$var2...)
