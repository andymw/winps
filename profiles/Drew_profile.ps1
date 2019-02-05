# Windows PowerShell 3.0 Profile
# Drew Weymouth
# Last Modified: 2014-02-12

#Locations
$cornell = "D:\Documents\Academic\Cornell\"
$cygbin = "C:\Program Files\cygwin\bin"
$foobar = "D:\Music\foobar2000"
$bin = "$HOME\Programs"

#SVN
$scripts = "D:\Documents\WindowsPowerShell\"
$txtenc = "D:\Documents\EclipseWorkspace\TextEncryption\"
$super8 = "D:\Documents\EclipseWorkspace\Super8\"
$moviereviews = "D:\Documents\MovieReviews"
$svn = @($scripts,$txtenc,$super8,$moviereviews)

Remove-Item -Force -ErrorAction SilentlyContinue alias:\man #Cygwin
Remove-Item -Force -ErrorAction SilentlyContinue alias:\diff #Cygwin
Remove-Item -Force -ErrorAction SilentlyContinue alias:\rm #Cygwin
Remove-Item -Force -ErrorAction SilentlyContinue alias:\ls #Cygwin
Remove-Item -Force -ErrorAction SilentlyContinue alias:\echo #Cygwin
Remove-Item -Force -ErrorAction SilentlyContinue alias:\cat #Cygwin

Remove-Item -Force -ErrorAction SilentlyContinue function:\mkdir #Cygwin

function : {}
function beep { Write-Output `a }
function computer { explorer '/root,' }

Remove-Item -Force -ErrorAction SilentlyContinue alias:\pwd
function pwd { Write-Output (Get-Location).ToString() }

New-Alias -Force find "$cygbin/find.exe"
# UNIX-style LS
function ls ([string]$1,[string]$2,[string]$3) {
	ls.exe -gAh --color=auto "$1" "$2" "$3"
}
# PDF word count
function pdfwc([string]$pdffile) { pdftotext "$pdffile" - | wc -w }

# Enable 'cd -' to go to previous directory
Remove-Item -Force -ErrorAction SilentlyContinue alias:\cd
$script:OLDPWD = (Get-Location)
function cd($dir) {
	if ($dir -eq '-') { $dir = $script:OLDPWD }
	$curdir = (Get-Location)
	Set-Location $dir -ErrorAction Stop
	$script:OLDPWD = $curdir
}

function maketex ($texfile) {
	latexmk -xelatex -quiet (Resolve-Path $texfile); latexmk -c
}

function which ($command) {
	Get-Command -All $command | Select-Object CommandType,DisplayName,Path `
		| Format-Table -Autosize | head -n -1
}

# Make > operater output ascii instead of UTF-16
function out-file($FilePath, $Encoding, [switch]$Append) {
	$input | microsoft.powershell.utility\out-file $filepath `
	-encoding:ascii -append:$append
}

function prompt {
	$loc = (Get-Location).ToString()
	if ($loc.StartsWith($cornell)) {
		$loc = '$cornell\' + $loc.Substring($cornell.Length)
	} elseif ($loc.StartsWith("$HOME\")) {
		$loc = $loc.Substring($HOME.Length + 1)
	}
	$loc = Shorten-String $loc 55
	Write-Host -ForegroundColor 'Blue' -NoNewline "PS $loc>  "; "`b"
}

function fbackup([string]$command) {
	if ($command -eq 'start') {
		Get-Service FBackup5Srv | Start-Service
		Invoke-Item 'C:\Program Files (x86)\Softland\FBackup 5\FBackup.exe'
	} else {
		Get-Service FBackup5Srv | Stop-Service
		Get-Process bTray | Stop-Process
	}
}

. Load-ScriptAlias

# Application Launchers
New-Alias -Force acroread "C:\Program Files (x86)\Adobe\Reader 11.0\Reader\AcroRd32.exe"
New-Alias -Force audacity "C:\Program Files (x86)\Audacity\audacity.exe"
New-Alias -Force ccleaner "C:\Program Files\CCleaner\CCleaner64.exe"
New-Alias -Force defraggler "C:\Program Files\Defraggler\Defraggler64.exe"
New-Alias -Force eac "C:\Program Files (x86)\Exact Audio Copy\eac.exe"
New-Alias -Force eclipse "C:\Program Files\eclipse\eclipse.exe"
New-Alias -Force excel "C:\Program Files (x86)\Microsoft Office\Office12\EXCEL.exe"
New-Alias -Force firefox "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
New-Alias -Force foobar "C:\Program Files (x86)\foobar2000\foobar2000.exe"
New-Alias -Force gimp "C:\Program Files\GIMP 2\bin\gimp-2.8.exe"
New-Alias -Force handbrake "C:\Program Files\Handbrake\Handbrake.exe"
New-Alias -Force iexplore "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
New-Alias -Force matlab "C:\Program Files (x86)\MATLAB\R2010a Student\bin\matlab.exe"
New-Alias -Force notepad++ "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-Alias -Force npp notepad++
New-Alias -Force octave "C:\Program Files (x86)\Octave-3.6.2\bin\octave.exe"
New-Alias -Force picmgr "C:\Program Files (x86)\Microsoft Office\Office12\OIS.exe"
New-Alias -Force powerpoint "C:\Program Files (x86)\Microsoft Office\Office12\POWERPNT.exe"
New-Alias -Force powerpnt powerpoint
New-Alias -Force publisher "C:\Program Files (x86)\Microsoft Office\Office12\MSPUB.exe"
New-Alias -Force txtenc "$HOME\Programs\TextEncryption.exe"
New-Alias -Force utorrent "C:\Program files (x86)\uTorrent\uTorrent.exe"
New-Alias -Force vim "C:\Program Files\vim72\vim.exe"
New-Alias -Force vlc "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
New-Alias -Force word "C:\Program Files (x86)\Microsoft Office\Office12\WINWORD.exe"
