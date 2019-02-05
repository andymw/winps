<#
.SYNOPSIS
Checks a Gmail address for emails
.DESCRIPTION
Check-Gmail checks a specified Gmail address for new (unread) emails.
  The password for authentication will be prompted for automatically.
  Checks https://mail.google.com/mail/feed/atom for new entries.
  (Performs no effect on the mailbox itself: does not mark the items as read.)
.NOTES
Windows PowerShell 3.0 script
Written by Andy Wang
.PARAMETER Username
The Gmail username (Google account name). The '@gmail.com' is optional.
If not provided, the script will prompt for it automatically.
.PARAMETER Label
Check the label for new emails
.PARAMETER Get
Specify number of latest emails to display (default 10, min 0, max 256)
.PARAMETER ReturnXML
If specified, returns structured data.
.EXAMPLE
Check-Gmail anddwann
Check the account anddwann@gmail.com for new unread emails
  The password for authentication will be prompted for automatically.
.LINK
https://mail.google.com/mail/feed/atom
#>
[CmdletBinding()]
param (
    [Parameter(Position=0,Mandatory=$true)][string]$Username,
    [Parameter(Position=1)][string]$Label,
    [Parameter()][ValidateRange(0,256)][int]$Get = 10,
    [Parameter()][Alias("x")][switch]$ReturnXML
)

$BaseURL = 'https://mail.google.com/mail/feed/atom/'
$Label = $Label.Replace(' ','-').Replace('/','-')
$URL = "$BaseURL$Label"

if ($Username.Contains('@')) {
    $Username = $Username.Substring(0,$Username.IndexOf('@'))
    Write-Output "Username: $Username"
}

$FailAfter = 5 # for loop terminates after $FailAfter tries
for ($idx = 0; ($idx -lt $FailAfter) -and (!$title -or !$count); $idx++) {
    $password = Read-Host -Prompt `
        "Enter host password for user '$Username'" -AsSecureString
    $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto( `
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    [xml]$xml = curl -L -k -s -A PowerShell `
        -u ${Username}:${password} $URL
    $password = $null

    $title = $xml.feed.title
    $count = $xml.feed.fullcount
    if (!$title -or !$count -and $idx -lt $FailAfter - 1) {
        Write-Warning "Could not authenticate (Ctrl+C to stop)"
    }
}
if (!$title -or !$count) {
    Write-Error "Could not complete authentication for $Username"; exit
}
if ($ReturnXML) { return $xml.feed }

if ($count -eq 1) { $str = "EMAIL" }
else { $str = "EMAILS" }
Write-Output "`n`t$title - $count UNREAD $str"
if ($Get -lt $count) {
    if ($Get -eq 1) { $str = "email" }
    else { $str = "emails" }
    Write-Output "`t(showing the latest $Get $str)"
}

$idx = 0;
foreach ($entry in $xml.feed.entry) {
    if ($idx -ge $Get) { break }
    Write-Output "`nFrom:    $($entry.author.name) ($($entry.author.email))"
    Write-Output "Sent:    $($entry.modified)"
    Write-Output "Subject: $($entry.title)"
    Write-Output "Summary: $($entry.summary)"
    Write-Output "Link:    $($entry.link.href)"
    $idx++;
}
Write-Output ''
