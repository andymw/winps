<#
.SYNOPSIS
Sends emails using Gmail (by default)
.DESCRIPTION
Sends emails SMTP Gmail server smtp.gmail.com, port 587 by default.
  When invoked without any parameters, the cmdlet prompts for each field.
  Does not support attachments or anything other than plaintext.
  Follows SMTP protocol:
    supports 1 From address, multiple To addresses, subject, and body.
.NOTES
Windows PowerShell 3.0 script
.EXAMPLE
Send-Email -s Subject -b Body -f from@gmail.com -t 'to1@gmail.com,to2@gmail.com'
Sends an email from 'from@gmail.com' to 'to1@gmail.com' and 'to2@gmail.com'
  with the subject 'Subject' and body 'Body'.
.LINK
Send-MailMessage
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][string]$From, # TODO ValidatePattern
    [Parameter(Mandatory=$true)][string[]]$To, # TODO ValidatePattern
    [Parameter()][Alias("s")][string]$Subject,
    [Parameter()][string[]]$Body,
    [Parameter()][string[]]$Attachments,
    [Parameter()][string]$SMTPServer = 'smtp.gmail.com',
    [Parameter()][int]   $SMTPPort   = 587,
    [Parameter()][switch]$EnableSSL  = $true
)

# Prompt for subject/body
if (!$Subject) {
    $Subject = Read-Host -Prompt 'Subject'
}
if (!$Body) {
    $i = 0
    do {
        $newline = Read-Host -Prompt "Body[$i]"
        $Body += $newline
        $i += 1
    } while ($newline)
}

# Build mail object
$mail = New-Object System.Net.Mail.MailMessage;
$mail.From = New-Object System.Net.Mail.MailAddress($From);
$mail.Subject = $Subject
foreach ($member in $To) {
    $mail.To.Add($member);
}
$Msg = ''
foreach ($line in $Body) {
    $Msg += $line.Replace('\n',"`n").Replace('`n',"`n") + "`n"
}
$mail.Body = $Msg

foreach ($file in $Attachments) {
    try {
        $file = Resolve-Path $file -ErrorAction Stop
        $att = New-Object System.Net.Mail.Attachment($file)
        $mail.Attachments.Add($att)
        $attach += @($att) # add to array to be disposed of after send
    } catch {
        Write-Warning "File $file not found."
    }
}

$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
$SMTPClient.EnableSsl = $EnableSSL

# Establish authentication
$username = $From.Substring(0,$From.IndexOf('@'))

Write-Output ''
$FailAfter = 5 # do-while loop terminates after $FailAfter tries
for ($idx = 0; $idx -lt $FailAfter -and !$success; $idx++) {
    $password = Read-Host -Prompt "Enter password for $From" -AsSecureString
    $SMTPClient.Credentials = `
        New-Object System.Net.NetworkCredential($username,$password);
    try {
        $SMTPClient.Send($mail)
        $success = $true
    } catch {
        if ($idx -lt $FailAfter - 1) {
            Write-Warning 'Unable to authenticate. (Ctrl+C to stop)'
        } else {
            Write-Error "Could not complete authentication for $From"
        }
    }
}

foreach ($att in $attach) {
    $att.Dispose()
}
