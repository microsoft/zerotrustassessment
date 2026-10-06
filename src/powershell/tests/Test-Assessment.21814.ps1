
<#
.SYNOPSIS
    Checks that privileged accounts are cloud native identities.

.NOTES
    Test ID: 21814
    Pillar: Identity
    Category: Privileged access
    Data source: Exported role assignments and user data
#>

function Test-Assessment-21814 {
    [ZtTest(
        Category = 'Privileged access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Free'),
        Pillar = 'Identity',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 21814,
        Title = 'Privileged accounts are cloud native identities',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking privileged accounts are cloud native identities'
    Write-ZtProgress -Activity $activity -Status 'Loading exported role assignments'

    # Role assignments, expanded privileged-group members, and user sync status are exported.
    $sql = @"
SELECT DISTINCT
    vr.roleDisplayName,
    cast(vr.principalId AS varchar) AS id,
    coalesce(cast(u.displayName AS varchar), vr.principalDisplayName) AS displayName,
    coalesce(u.onPremisesSyncEnabled, false) AS onPremisesSyncEnabled
FROM main.vwRole vr
LEFT JOIN main."User" u ON vr.principalId = u.id
WHERE vr.isPrivileged = 1
    AND vr."@odata.type" = '#microsoft.graph.user'
ORDER BY vr.roleDisplayName, displayName
"@

    $privilegedRoleUsers = @(Invoke-DatabaseQuery -Database $Database -Sql $sql)
    foreach ($user in $privilegedRoleUsers) {
        $user.onPremisesSyncEnabled = $user.onPremisesSyncEnabled -eq $true
    }
    #endregion Data Collection

    #region Assessment Logic
    $syncedPrivilegedRoleUsers = @($privilegedRoleUsers | Where-Object { $_.onPremisesSyncEnabled -eq $true })
    $passed = $syncedPrivilegedRoleUsers.Count -eq 0

    if ($passed) {
        $testResultMarkdown += "Validated that standing or eligible privileged accounts are cloud only accounts.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "This tenant has $($syncedPrivilegedRoleUsers.Count) privileged users that are synced from on-premises.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = "## Privileged roles`n`n"
    $mdInfo += "| Role name | User | Source | Status |`n"
    $mdInfo += "| :--- | :--- | :--- | :---: |`n"
    foreach ($user in $privilegedRoleUsers) {
        if ($user.onPremisesSyncEnabled -eq $true) {
            $type = "Synced from on-premises"
            $status = "❌"
        }
        else {
            $type = "Cloud native identity"
            $status = "✅"
        }

        $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/{0}" -f $user.id
        $mdInfo += "| $($user.roleDisplayName) | [$($user.displayName)]($userLink) | $type | $status |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId = '21814'
        Title  = 'Privileged accounts are cloud native identities'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
    #endregion Report Generation
}
