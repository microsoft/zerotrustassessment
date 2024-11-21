
<#
.SYNOPSIS

#>

function Test-InactiveAppDontHaveHighPrivGraphPerm {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $sql = @"
    select sp.id, sp.appId, sp.displayName, sp.appOwnerOrganizationId,
    spsi.lastSignInActivity.lastSignInDateTime
    from main.ServicePrincipal sp
        left join main.ServicePrincipalSignIn spsi on spsi.appId = sp.appId
    where sp.id in
        (
            select sp.id
            from main.ServicePrincipal sp
            where sp.oauth2PermissionGrants.scope is not null
        )
        or sp.id in
        (
            select distinct sp.id,
            from (select sp.id, sp.displayName, unnest(sp.appRoleAssignments).AppRoleId as appRoleId
                from main.ServicePrincipal sp) sp
                left join
                    (select unnest(main.ServicePrincipal.appRoles).id as id, unnest(main.ServicePrincipal.appRoles)."value" permissionName
                    from main.ServicePrincipal) spAppRole
                    on sp.appRoleId = spAppRole.id
            where permissionName is not null
        )
    order by spsi.lastSignInActivity.lastSignInDateTime
"@

    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $inactiveRiskyApps = @()
    $otherApps = @()

    foreach($item in $results) {
        $item = Add-DelegatePermissions $item
        $item = Add-AppPermissions $item
        $item = Add-GraphRisk $item
        if([string]::IsNullOrEmpty($item.lastSignInDateTime) -and $item.IsRisky) {
            $inactiveRiskyApps += $item
        }
        else {
            $otherApps += $item
        }
    }

    $passed = $inactiveRiskyApps.Count -eq 0

    if ($passed) {
        $testResultMarkdown += "No inactive applications with high privileges`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Inactive Application(s) with high privileges were found`n`n%TestResult%"
    }

    $mdInfo = "`n## Apps with privileged Graph permissions`n`n"
    $mdInfo += "| | Name | Risk | Delegate Permission | Application Permission | App owner tenant | Last sign in|`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"
    $mdInfo += Get-AppList -Apps $inactiveRiskyApps -Icon "❌"
    $mdInfo += Get-AppList -Apps $otherApps -Icon "✅"


    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21770' -Title 'Inactive applications don''t have highly privileged permissions' `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Add-DelegatePermissions($item) {
    $sql = @"
    select sp.id, sp.oauth2PermissionGrants.scope as permissionName,
    from main.ServicePrincipal sp
    where sp.oauth2PermissionGrants.scope is not null
    and sp.id == '{0}'
"@
    $sql = $sql -f $item.id
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $item.DelegatePermissions = @()
    if($results.permissionName) {
        $perms = $results.permissionName.trim() -replace """", ""
        $item.DelegatePermissions = $perms -split " " | Where-Object { ![string]::IsNullOrEmpty($_)}
    }
    return $item
}

function Add-AppPermissions($item) {
    $sql = @"
    select distinct spAppRole.*
    from (select sp.id, sp.displayName, unnest(sp.appRoleAssignments).AppRoleId as appRoleId
        from main.ServicePrincipal sp) sp
        left join
            (select unnest(main.ServicePrincipal.appRoles).id as id, unnest(main.ServicePrincipal.appRoles)."value" permissionName
            from main.ServicePrincipal) spAppRole
            on sp.appRoleId = spAppRole.id
    where permissionName is not null and sp.id == '{0}'
"@
    $sql = $sql -f $item.id
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $item.AppPermissions = $results.permissionName
    return $item
}

function Add-GraphRisk($item) {
    $item.Risk = Get-GraphRisk -delegatePermissions $item.DelegatePermissions -applicationPermissions $item.AppPermissions
    $item.IsRisky = $item.Risk -eq "High"
    return $item
}

function Get-AppList($Apps, $Icon) {
    $mdInfo = ""
    foreach ($item in $apps) {
        $tenant = Get-ZtTenant -tenantId $item.appOwnerOrganizationId
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($item.id)/appId/$($item.appId)"
        $risk = $item.Risk
        $delPerm = $item.DelegatePermissions -join ", "
        $appPerm = $item.AppPermissions -join ", "
        $mdInfo += "| $($Icon) | [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $risk | $delPerm | $appPerm | $(Get-SafeMarkdown($tenant.displayName)) | $(Get-FormattedDate($item.lastSignInDateTime)) | `n"
    }
    return $mdInfo
}

function Get-GraphRisk($delegatePermissions, $applicationPermissions) {
    $finalRisk = "Unranked"
    foreach($permission in $applicationPermissions){
        $risk = Get-GraphPermissionRisk -Permission $permission -PermissionType "Application"
        switch($risk){
            "High" { return $risk }
            "Medium" { $finalRisk = $risk }
        }
    }
    foreach($permission in $delegatePermissions){
        $risk = Get-GraphPermissionRisk -Permission $permission -PermissionType "Delegated"
        switch($risk){
            "High" { return $risk }
            "Medium" { $finalRisk = $risk }
        }
    }
    return $finalRisk
}
