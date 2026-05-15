<#
.SYNOPSIS
    Safely toggles PSFramework's console-interrupt handler on consoleless hosts.

.DESCRIPTION
    Wraps Disable-PSFConsoleInterrupt / Enable-PSFConsoleInterrupt and swallows the
    System.IO.IOException ("The handle is invalid", HResult 0x80070006) that is thrown
    on hosts without a real console (CI agents, Default Host, etc.). Any other
    exception is rethrown. Locale-independent — uses the exception TYPE, not the
    message string, so it works on non-English Windows.

.PARAMETER Disable
    Calls Disable-PSFConsoleInterrupt.

.PARAMETER Enable
    Calls Enable-PSFConsoleInterrupt.
#>
function Invoke-ZtSafeConsoleInterruptToggle {
    [CmdletBinding(DefaultParameterSetName = 'Disable')]
    param(
        [Parameter(ParameterSetName = 'Disable', Mandatory)] [switch]$Disable,
        [Parameter(ParameterSetName = 'Enable',  Mandatory)] [switch]$Enable
    )

    $action = if ($Disable) { 'Disable' } else { 'Enable' }
    try {
        if ($Disable) { Disable-PSFConsoleInterrupt -ErrorAction Stop }
        else          { Enable-PSFConsoleInterrupt  -ErrorAction Stop }
    }
    catch [System.IO.IOException] {
        Write-PSFMessage -Level Verbose -Message "$action-PSFConsoleInterrupt skipped (no console handle): $_"
    }
}
