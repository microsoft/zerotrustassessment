
<#
.SYNOPSIS
    Checks that admins are not synced from on-prem
#>

function Test-St0002AppsNotUsedInLast90Days {
    [CmdletBinding()]
    param(
        $Database
    )

    $activity = "Checking inactive apps"
    Write-ZtProgress -Activity $activity -Status "Starting"

    $sql = @"
select app.id, app."displayName", spSignIns."lastSignInActivity"."lastSignInDateTime" as lastSignInDateTime, app."createdDateTime"
from main."Application" as app
    left join main."ServicePrincipalSignIn" as spSignIns
    on app.appid = spSignIns."appId"
where datediff('day', try_cast(spSignIns."lastSignInActivity"."lastSignInDateTime" as date), today()) > 90
order by spSignIns."lastSignInActivity"."lastSignInDateTime" desc
"@

    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

    $appCount =  $results.Count
    Write-Verbose "AppCount: $appCount"
    $passed = ($appCount -eq 0)

    if ($passed) {
        $testResultMarkdown += "No stale apps were detected in the tenant. ✅"
    }
    else {
        $testResultMarkdown += "This tenant has $appCount apps that haven't been signed into for more than 90 days. ❌`n`n%TestResult%"
    }

    #TODO: Make user names clickable
    $mdInfo = "## Stale applications`n`n"
    $mdInfo += "| Application | Date created | Last sign in |`n"
    $mdInfo += "| :--- | :--- | :--- |`n"
    foreach ($app in $results) {
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/{0}" -f $app.id
        $mdInfo += "| [$(Get-SafeMarkdown($app.displayName))]($portalLink) | $($app.createdDateTime) | $($app.lastSignInDateTime) |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId 'ST0002' -Title 'Inactive apps not signed in over 90 days' `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
