<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        # The folder that has the test data
        [Parameter(Mandatory = $true)]
        $Database
    )

    # Maybe optimize in future to run tests in parallel, show better progress etc.
    # We could also run all the cmdlets in this folder that start with Test-
    # For now, just run all tests sequentially

    Test-St0002AppsNotUsedInLast90Days -Database $Database
    Test-St0018GuestShouldNotInviteGuests
    Test-St0009PhishingResistantAuthForAdmins
    Test-St0020BlockLegacyAuth
    Test-St0024MfaForAllUsers
    Test-St0030UserCannotRegisterApps
    Test-St0037PrivilegedRolesAreCloudOnly

    return Get-ZtTestResults
}
