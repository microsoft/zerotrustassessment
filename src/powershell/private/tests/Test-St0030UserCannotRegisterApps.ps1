<#
.SYNOPSIS
    Checks that user is not able to register apps.
#>

function Test-St0030UserCannotRegisterApps {
    [CmdletBinding()]
    param()

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $passed = $result.defaultUserRolePermissions.allowedToCreateApps -eq $false

    if ($passed) {
        $testResultMarkdown = "Tenant is configured to prevent users from registering applications.`n`n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅"
    } else {
        $testResultMarkdown = "Tenant allows all non-privileged users to register applications.`n`n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **Yes** ❌"
    }

    Add-ZtTestResultDetail -TestId 'ST0030' -Title 'Registering applications is restricted to privileged users' -Impact High `
        -Likelihood HighlyLikely -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
