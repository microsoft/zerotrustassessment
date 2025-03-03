<#
    Returns the status of the test as a string.
#>
function Get-ZtTestStatus{
    [CmdletBinding()]
    param(
        # The status of the test.
        [Parameter(Mandatory = $true)]
        [bool] $Status,

        # Whether the test was skipped.
        [string] $SkippedBecause
    )

    if ($Status) {
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
            return "Skipped"
        }
    }

    return $Status
}
