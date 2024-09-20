
<#
.SYNOPSIS

#>

function Test-InactiveAppDontHaveHighPrivEntraRole {
    [CmdletBinding()]
    param(
        $Database
    )

    $sql = @"
    select distinct r.principalId, r.principalDisplayName, r.principalOrganizationId,
        spsi.lastSignInActivity.lastSignInDateTime, r.privilegeType, sp.appId
    from main.vwRole r
        left join main.ServicePrincipal sp on r.principalId = sp.id
        left join main.ServicePrincipalSignIn spsi on spsi.appId = sp.appId
    where r."@odata.type" == '#microsoft.graph.servicePrincipal' and r."isPrivileged" = true
    order by spsi."lastSignInActivity".lastSignInDateTime
"@

    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

    $inactiveApps = @()
    $activeApps = @()
    foreach($item in $results) {
        if([string]::IsNullOrEmpty($item.lastSignInDateTime)) { $inactiveApps += $item }
        else { $activeApps += $item }
    }

    $passed = $inactiveApps.Count -eq 0

    if ($passed) {
        $testResultMarkdown += "No inactive applications with privileged Entra built-in roles`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Found $($inactiveApps.Count) inactive applications with privileged Entra built-in roles`n`n%TestResult%"
    }

    if ($results.Count -gt 0) {
        $mdInfo = "`n## Apps with privileged Entra built-in roles`n`n"
        $mdInfo += "| | Name | Role | Assignment | App owner tenant | Last sign in|`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"
        $mdInfo += Get-AppListRole -Apps $inactiveApps -Icon "❌"
        $mdInfo += Get-AppListRole -Apps $activeApps -Icon "✅"
    }
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21771' -Title 'Inactive applications don'’t have highly privileged Microsoft Entra built-in roles' `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-AppListRole($Apps, $Icon) {
    $mdInfo = ""
    $sqlRole = @"
    select r.roleDisplayName
    from main.vwRole r
    where r.principalId = '{0}' and r.isPrivileged = true
"@
    foreach ($item in $apps) {
        $role = Invoke-DatabaseQuery -Database $Database -Sql ($sqlRole -f $item.principalId)
        $roleDisplayName = $role.roleDisplayName -join ", "
        $tenant = Get-ZtTenant -tenantId $item.principalOrganizationId
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($item.principalId)/appId/$($item.appId)"
        $mdInfo += "| $($Icon) | [$(Get-SafeMarkdown($item.principalDisplayName))]($portalLink) | $roleDisplayName | $($item.privilegeType) | $(Get-SafeMarkdown($tenant.displayName)) | $(Get-FormattedDate($item.lastSignInDateTime)) | `n"
    }
    return $mdInfo
}
