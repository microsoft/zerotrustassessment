<#
    Returns the status of the test as a string.
#>
function Get-ZtTestStatus {
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The status of the test.
        [Parameter(Mandatory = $true)]
        [bool] $Status,

        # Whether the test was skipped.
        [string] $SkippedBecause,

        # Optional. Custom status to return instead of the default status.
        [ValidateSet('Investigate','Error')]
        [string] $CustomStatus
    )

    if ($CustomStatus) {
        return $CustomStatus
    }
    elseif ($Status) {
        return "Passed"
    }
    else {
        if ([string]::IsNullOrEmpty($SkippedBecause)) {
            return "Failed"
        }
        else {
            if ($SkippedBecause -eq "UnderConstruction") {
                return "Planned"
            }
            else {
                return "Skipped"
            }
        }
    }
}
