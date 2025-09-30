
<#
.SYNOPSIS

#>

function Test-Assessment-21770 {
	[ZtTest(
		Category = 'Access control',
		ImplementationCost = 'Low',
		Pillar = 'Identity',
		RiskLevel = 'Medium',
		SfiPillar = 'Protect engineering systems',
		TenantType = ('Workforce','External'),
		TestId = 21770,
		Title = 'Inactive applications don’’t have highly privileged Microsoft Graph API permissions',
		UserImpact = 'High'
	)]
    [CmdletBinding()]
    param(
        $Database
    )

    # Import shared cmdlets
    . "$PSScriptRoot/../private/tests-shared/Add-DelegatePermissions.ps1"
    . "$PSScriptRoot/../private/tests-shared/Add-AppPermissions.ps1"
    . "$PSScriptRoot/../private/tests-shared/GraphRisk.ps1"
    . "$PSScriptRoot/../private/tests-shared/Get-AppList.ps1"


    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $sql = @"
    select sp.id, sp.appId, sp.displayName, sp.appOwnerOrganizationId, sp.publisherName,
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
        $item = Add-DelegatePermissions -item $item -Database $Database
        $item = Add-AppPermissions -item $item -Database $Database
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
