<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        # The folder that has the test data
        [string]
        [Parameter(Mandatory = $true)]
        $Path
    )

    # Maybe optimize in future to run tests in parallel, show better progress etc.
    # We could also run all the cmdlets in this folder that start with Test-
    # For now, just run all tests sequentially

    Test-St0018GuestShouldNotInviteGuests
    Test-St0009PhishingResistantAuthForAdmins

    return Get-ZtTestResults
}
