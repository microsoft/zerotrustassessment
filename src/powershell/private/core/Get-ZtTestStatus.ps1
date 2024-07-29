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
        [bool] $Skipped
    )

    if ($Status) {
        return "Passed"
    }
    else {
        if ($Skipped) {
            return "Skipped"
        }
        else {
            return "Failed"
        }
    }

    return $Status
}
