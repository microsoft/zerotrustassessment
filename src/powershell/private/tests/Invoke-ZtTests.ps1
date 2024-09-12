<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        $Database
    )

    # Maybe optimize in future to run tests in parallel, show better progress etc.
    # We could also run all the cmdlets in this folder that start with Test-
    # For now, just run all tests sequentially

    Test-InactiveAppDontHaveHighPrivGraphPerm -Database $Database
    Test-InactiveAppDontHaveHighPrivEntraRole -Database $Database
    Test-AppDontHaveSecrets -Database $Database
    Test-AppDontHaveCertsWithLongExpiry -Database $Database
    Test-PrivilegedUsersSignInPhishResistant
    Test-PrivilegedUsersCaAuthStrengthPhishResistant
    Test-PrivilegedUsersPhishResistantMethodRegistered
    Test-GuestCantInviteGuests
    Test-GuestHaveRestrictedAccess
    Test-BlockLegacyAuthCaPolicy

    # Test-St0002AppsNotUsedInLast90Days -Database $Database

    # Test-St0024MfaForAllUsers
    # Test-St0030UserCannotRegisterApps
    # Test-St0037PrivilegedRolesAreCloudOnly
}
