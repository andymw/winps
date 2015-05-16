<#
.SYNOPSIS
Performs operations on environment variables.
.DESCRIPTION
Set-EnvironmentVariable performs operations on environment variables.
  Parameters:   -Variable   the variable name
                -Value      the new value to set variable
                -New        CREATE a new environment variable
                -Remove     removes an environment variable
                -User       User EnvironmentVariableTarget (User variable)
Operates only on 'User' and 'Machine' Environment Variable Targets.
Notes on operation:
  If no parameters are specified, script returns all variables
  If -Remove is specified with -New or -Value:
    -New and -Value take precedence and -Remove is not executed
.NOTES
Windows PowerShell 3.0 script
Written by Andy Wang
.PARAMETER Variable
The name of the environment variable. Positional parameter
.PARAMETER Value
The value with which to set the environment variable. Positional parameter
Prompts for variable name if name is unspecified.
.PARAMETER New
Switch parameter allows creation of a new environment variable.
If the variable exists already, the operation proceeds normally
User is prompted for variable name and value if these are unspecified
.PARAMETER Remove
Removes a named environment variable.
Prompts for variable name if name is unspecified.
If -Remove is specified with -New or -Value:
  -New and -Value take precedence and -Remove is not executed
.PARAMETER User
Switch to specify the User EnvironmentVariableTarget for user variables
.EXAMPLE
Set-EnvironmentVariable
Lists environment variables in a table
.EXAMPLE
Set-EnvironmentVariable term
Gets the value of the system environment variable TERM.
.EXAMPLE
Set-EnvironmentVariable term cygwin
Sets the value of the system environment variable TERM to 'cygwin'
.EXAMPLE
Set-EnvironmentVariable -u -n test testvalue
Creates a user variable 'test' and sets its value to 'testvalue'
.EXAMPLE
Set-EnvironmentVariable -rm -u test
Remove the user variable 'test'
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Position=0)][string]$Variable,
    [Parameter(Position=1)][Alias("v")][string]$Value,
    [Parameter()][switch]$New,
    [Parameter()][Alias("rm")][switch]$Remove,
    [Parameter()][switch]$User,
    [Parameter()][switch]$help
)

if ($help) {
    Get-Help $MyInvocation.MyCommand.path; exit
}

if (!$Variable -and !$Value -and !$New -and !$Remove) { # list env variables
    return Get-ChildItem -Path Env:\
} elseif ($Value -or $New -or $Remove -and !$Variable) { # prompt name
    $Variable = Read-Host -Prompt "Enter environment variable name"
    if (!$Variable) { # user left the prompt unspecified
        Write-Error "Environment variable name unspecified."; exit
    }
}
if ($New -and !$Value) { # prompt value
    $Value = Read-Host -Prompt "Enter environment variable value"
    if (!$Value) { # user left the prompt unspecified
        Write-Error "Environment variable value unspecified."; exit
    }
}

# search 'Machine' and 'User' targets for the variable.
if ($User) {
    $target1 = 'User'; $target2 = 'Machine';
    $tname1  = 'User'; $tname2  = 'System';
} else {
    $target1 = 'Machine'; $target2 = 'User';
    $tname1  = 'System';  $tname2  = 'User';
}

# get environment variable if exists
$varval1 = [System.Environment]::GetEnvironmentVariable(
    $Variable, [System.EnvironmentVariableTarget]::$target1
)
$varval2 = [System.Environment]::GetEnvironmentVariable(
    $Variable, [System.EnvironmentVariableTarget]::$target2
)

if ($varval1) {
    Write-Output "`n$Variable=$varval1"
} elseif (!$New) {
    $message += "$tname1 environment variable '$Variable' not found"
    if (!$varval2) {
        Write-Error $message
    } else {
        $message += "`n`tDid you mean the $tname2 variable '$Variable'"
        $message += " with value '$varval2'?`n"
        if (!$User) {
            $message += "`tInclude '-u' to access the $tname2 variable`n"
        } else {
            $message += "`tOmit '-u' to access the $tname2 variable`n"
        }
        Write-Warning $message
    }
    exit
}
if (!$Value -and !$Remove) { Write-Output ''; exit } # done

if ($Value) { # SET environment variable
    if ($PSCmdlet.ShouldProcess($Variable,"Set variable value to '$Value'")) {
        Write-Output "Setting value of variable '$Variable' to '$Value' ..."
        [System.Environment]::SetEnvironmentVariable(
            $Variable, $Value, [System.EnvironmentVariableTarget]::$target1
        )
        if ($User -or !$varval2) { # set Env:\$Variable conditionally
            Set-Item -Path Env:\$Variable -Value $Value
        }
        Write-Output "Done!"
    }
} elseif ($Remove) { # REMOVE environment variable
    if ($PSCmdlet.ShouldProcess($Variable,"Remove variable")) {
        Write-Output "Removing variable '$Variable' with value '$varval1' ..."
        [System.Environment]::SetEnvironmentVariable(
            $Variable, $null, [System.EnvironmentVariableTarget]::$target1
        )
        # set Env:\$Variable to other value (if exists, else null)
        Set-Item -Path Env:\$Variable -Value $varval2
        Write-Output "Done!"
    }
} else { # WHAT
    Write-Error 'SHOULD NOT HAPPEN'; exit
}
Write-Output ''
