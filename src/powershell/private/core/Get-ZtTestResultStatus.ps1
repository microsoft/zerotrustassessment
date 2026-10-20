<#
.SYNOPSIS
    Returns the roll-up status of a check that has already run.

.DESCRIPTION
    Composite dashboards need to know whether a child check passed, failed, returned Investigate,
    or never produced a verdict at all. Returns $null when the check was not run, so callers can
    distinguish an unavailable child from one that genuinely reported zero findings.

.EXAMPLE
    Get-ZtTestResultStatus -TestId '25395'

    Returns 'Passed', 'Failed', 'Investigate', 'Skipped', 'Planned', 'Error' or $null.
#>

function Get-ZtTestResultStatus {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The id of the check to read the roll-up status for.
        [Parameter(Mandatory = $true)]
        [string] $TestId
    )

    $script:__ZtSession.TestResultDetail.Value[$TestId].TestStatus
}
