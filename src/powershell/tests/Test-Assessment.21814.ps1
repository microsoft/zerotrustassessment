
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
    u.id IS NOT NULL AS userRecordFound,
    coalesce(u.onPremisesSyncEnabled, false) AS onPremisesSyncEnabled
FROM main.vwRole vr
LEFT JOIN main."User" u ON vr.principalId = u.id
WHERE vr.isPrivileged = 1
    AND vr."@odata.type" = '#microsoft.graph.user'
ORDER BY vr.roleDisplayName, displayName
"@

    $privilegedRoleUsers = @(Invoke-DatabaseQuery -Database $Database -Sql $sql)
    foreach ($user in $privilegedRoleUsers) {
        $user.userRecordFound = $user.userRecordFound -eq $true
        $user.onPremisesSyncEnabled = $user.onPremisesSyncEnabled -eq $true
    }
    #endregion Data Collection

    #region Assessment Logic
    $syncedPrivilegedRoleUsers = @($privilegedRoleUsers | Where-Object { $_.onPremisesSyncEnabled -eq $true } |
        Select-Object -Property id -Unique)
    $usersMissingFromExport = @($privilegedRoleUsers | Where-Object { -not $_.userRecordFound } |
        Select-Object -Property id -Unique)
    $hasUnresolvedData = $usersMissingFromExport.Count -gt 0
    $passed = $syncedPrivilegedRoleUsers.Count -eq 0 -and -not $hasUnresolvedData
    $customStatus = $null

    # A confirmed synced account is a failure; missing records make an otherwise clean result inconclusive.
    if ($syncedPrivilegedRoleUsers.Count -gt 0) {
        $userLabel = if ($syncedPrivilegedRoleUsers.Count -eq 1) { 'user' } else { 'users' }
        $testResultMarkdown = "This tenant has $($syncedPrivilegedRoleUsers.Count) distinct privileged $userLabel that are synced from on-premises.`n`n%TestResult%"
        if ($hasUnresolvedData) {
            $testResultMarkdown += "`n`nCould not verify $($usersMissingFromExport.Count) additional privileged user records because they are missing from the exported user data."
        }
    }
    elseif ($hasUnresolvedData) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "Could not verify $($usersMissingFromExport.Count) privileged user records because they are missing from the exported user data.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Validated that standing or eligible privileged accounts are cloud only accounts.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    if ($privilegedRoleUsers.Count -gt 0) {
        $exceptionRoleUsers = @($privilegedRoleUsers | Where-Object {
            -not $_.userRecordFound -or $_.onPremisesSyncEnabled -eq $true
        })
        # Keep the report focused on actionable rows; cap large result sets to avoid oversized reports.
        if ($exceptionRoleUsers.Count -gt 0) {
            $reportRoleUsers = $exceptionRoleUsers | Select-Object -First 50
            $omittedRoleUsers = $exceptionRoleUsers.Count - $reportRoleUsers.Count
        }
        else {
            $reportRoleUsers = $privilegedRoleUsers | Select-Object -First 10
            $omittedRoleUsers = $privilegedRoleUsers.Count - $reportRoleUsers.Count
        }

        $mdInfo = "## Privileged roles`n`n"
        $mdInfo += "| Role name | User | Source | Status |`n"
        $mdInfo += "| :--- | :--- | :--- | :---: |`n"
        foreach ($user in $reportRoleUsers) {
            if (-not $user.userRecordFound) {
                $type = 'User data unavailable'
                $status = '⚠️'
            }
            elseif ($user.onPremisesSyncEnabled -eq $true) {
                $type = 'Synced from on-premises'
                $status = '❌'
            }
            else {
                $type = 'Cloud native identity'
                $status = '✅'
            }

            $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/{0}" -f $user.id
            $mdInfo += "| $($user.roleDisplayName) | [$($user.displayName)]($userLink) | $type | $status |`n"
        }
        if ($omittedRoleUsers -gt 0) {
            if ($exceptionRoleUsers.Count -gt 0) {
                $mdInfo += "`nShowing the first $($reportRoleUsers.Count) of $($exceptionRoleUsers.Count) failed or unresolved privileged role assignments; additional rows were omitted.`n"
            }
            else {
                $mdInfo += "`nShowing the first $($reportRoleUsers.Count) of $($privilegedRoleUsers.Count) cloud-only privileged role assignments; additional rows were omitted.`n"
            }
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    $params = @{
        TestId = '21814'
        Title  = 'Privileged accounts are cloud native identities'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
    #endregion Report Generation
}
