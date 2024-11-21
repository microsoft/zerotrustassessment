<#
.SYNOPSIS
    Checks that user is not able to register apps.
#>

function Test-CreatingNewAppsRestrictedToPrivilegedUsers {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking user app registration policy"
    Write-ZtProgress -Activity $activity

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $passed = $result.defaultUserRolePermissions.allowedToCreateApps -eq $false

    if ($passed) {
        $testResultMarkdown = "Tenant is configured to prevent users from registering applications.`n`n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅"
    }
    else {
        $testResultMarkdown = "Tenant allows all non-privileged users to register applications.`n`n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **Yes** ❌"
    }

    Add-ZtTestResultDetail -TestId '21807' -Title 'Creating new applications and service principles is restricted to privileged users' `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
