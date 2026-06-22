<#
.SYNOPSIS
    Least privilege Intune RBAC roles are assigned instead of relying only on full Intune Administrator.

.DESCRIPTION
    Checks whether at least one Intune RBAC role assignment exists with one or more members,
    demonstrating that the tenant delegates Intune administration through scoped, least-privilege
    roles rather than relying exclusively on the full tenant-wide Microsoft Entra Intune
    Administrator role. Active full Intune Administrator assignments are surfaced as informational
    context alongside any Intune RBAC role assignments found.

.NOTES
    Test ID: 51021
    Category: Devices
    Pillar: Devices
    Required API: Microsoft Graph beta — roleManagement/directory/roleAssignmentScheduleInstances (Q2, informational Entra admin context)
                  deviceManagement/roleDefinitions (Q3)
                  deviceManagement/roleDefinitions/{id}/roleAssignments (Q4)
#>

function Test-Assessment-51021 {
    [ZtTest(
        Category = 'Devices',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'Medium',
        Pillar = 'Devices',
        RiskLevel = 'Low',
        Service = ('Graph'),
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 51021,
        Title = 'Least privilege Intune RBAC roles are assigned instead of relying only on full Intune Administrator',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Intune RBAC role assignments for least-privilege evidence'

    # Q2: Retrieve active and eligible Intune Administrator role assignments via Graph.
    # templateId == roleDefinitionId for built-in Entra roles, so Q1 is skipped — the well-known GUID is used directly.
    # Failures here are non-fatal; the Entra admin rows are simply omitted from the output table.
    $intuneAdminRoleId = '3a2c62db-5318-420d-8d74-23affee5d9d5'
    Write-ZtProgress -Activity $activity -Status 'Retrieving Intune Administrator role assignments'
    $entraAdminAssignments = @()
    try {
        $entraAdminAssignments = @(Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/roleAssignmentScheduleInstances" -Filter "roleDefinitionId eq '$intuneAdminRoleId'" -QueryParameters @{ '$expand' = 'principal' } -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        Write-PSFMessage "Q2 — Failed to retrieve Intune Administrator role assignments: $_" -Level Warning
        $result = if ($_.Exception.Message -match '403|Forbidden|accessDenied|401|Unauthorized') {
            '⚠️ The Intune RBAC role assignments API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'
        }
        else {
            "⚠️ An error occurred while querying Intune Administrator role assignments: $($_.Exception.Message)"
        }
        $params = @{
            TestId       = '51021'
            Title        = 'Least privilege Intune RBAC roles are assigned instead of relying only on full Intune Administrator'
            Status       = $false
            Result       = $result
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q3: Retrieve all Intune RBAC role definitions (built-in and custom).
    Write-ZtProgress -Activity $activity -Status 'Retrieving Intune RBAC role definitions'
    $intuneRoleDefs = @()
    try {
        $intuneRoleDefs = @(Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/roleDefinitions' -Select 'id,displayName,isBuiltInRoleDefinition,isBuiltIn' -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        Write-PSFMessage "Q3 — Failed to retrieve Intune RBAC role definitions: $_" -Level Warning
        $result = if ($_.Exception.Message -match '403|Forbidden|accessDenied|401|Unauthorized') {
            '⚠️ The Intune RBAC role assignments API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'
        }
        else {
            "⚠️ An error occurred while querying Intune RBAC role definitions: $($_.Exception.Message)"
        }
        $params = @{
            TestId       = '51021'
            Title        = 'Least privilege Intune RBAC roles are assigned instead of relying only on full Intune Administrator'
            Status       = $false
            Result       = $result
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q4: Retrieve role assignments for each Intune RBAC role definition.
    $roleAssignmentMap = @{}
    if ($intuneRoleDefs.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving Intune RBAC role assignments'
        foreach ($roleDef in $intuneRoleDefs) {
            $roleAssignmentsUri = "deviceManagement/roleDefinitions/$($roleDef.id)/roleAssignments"
            try {
                $assignments = @(Invoke-ZtGraphRequest -RelativeUri $roleAssignmentsUri -ApiVersion beta -ErrorAction Stop)
                $roleAssignmentMap[$roleDef.id] = $assignments
            }
            catch {
                Write-PSFMessage "Q4 — Failed to retrieve role assignments for role '$($roleDef.displayName)': $_" -Level Warning
                $roleAssignmentMap[$roleDef.id] = @()
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    # Count Intune RBAC assignments that qualify as least-privilege evidence (at least one member).
    $qualifyingCount = 0
    foreach ($roleDef in $intuneRoleDefs) {
        foreach ($assignment in $roleAssignmentMap[$roleDef.id]) {
            if ($assignment.members -and @($assignment.members).Count -gt 0) {
                $qualifyingCount++
            }
        }
    }

    $passed = $qualifyingCount -gt 0

    if ($passed) {
        $testResultMarkdown = "✅ At least one Intune RBAC role is assigned, showing that the tenant uses least-privilege Intune administration instead of relying only on full Intune Administrator access.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No assigned Intune RBAC role was found. Intune administration appears to rely only on full Intune Administrator access or lacks least-privilege RBAC delegation.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/RolesLandingMenuBlade/~/roles'
    $maxRows    = 10

    # Map scopeType enum values to display-friendly strings.
    $scopeTypeLabels = @{
        allDevices                 = 'All Devices'
        allLicensedUsers           = 'All Licensed Users'
        allDevicesAndLicensedUsers = 'All Devices and Licensed Users'
        resourceScope              = 'Resource scope'
    }

    # Build all output rows: Entra admin rows first (informational), then Intune RBAC rows.
    $allRows = @()

    foreach ($adminAssignment in $entraAdminAssignments) {
        $principalName = if ($adminAssignment.principal.userPrincipalName) { $adminAssignment.principal.userPrincipalName }
                         elseif ($adminAssignment.principal.displayName)    { $adminAssignment.principal.displayName }
                         else                                               { $adminAssignment.principal.id }
        $allRows += [PSCustomObject]@{
            RoleSource     = 'Full Entra role'
            RoleName       = 'Intune Administrator'
            AssignmentName = "Active assignment — $(Get-SafeMarkdown $principalName)"
            MemberCount    = 1
            Scope          = 'Tenant-wide'
            RoleType       = 'Full admin'
            RowStatus      = 'Informational'
        }
    }

    foreach ($roleDef in $intuneRoleDefs) {
        $roleType    = if ($roleDef.isBuiltIn -or $roleDef.isBuiltInRoleDefinition) { 'Built-in' } else { 'Custom' }
        $roleDefName = Get-SafeMarkdown $roleDef.displayName
        foreach ($assignment in $roleAssignmentMap[$roleDef.id]) {
            $memberCount  = if ($assignment.members) { @($assignment.members).Count } else { 0 }
            $scopeDisplay = if ($scopeTypeLabels.ContainsKey($assignment.scopeType)) { $scopeTypeLabels[$assignment.scopeType] } else { $assignment.scopeType }
            $rowStatus    = if ($memberCount -gt 0) { '✅ Pass' } else { '❌ Fail' }
            $allRows += [PSCustomObject]@{
                RoleSource     = 'Intune RBAC'
                RoleName       = $roleDefName
                AssignmentName = Get-SafeMarkdown $assignment.displayName
                MemberCount    = $memberCount
                Scope          = $scopeDisplay
                RoleType       = $roleType
                RowStatus      = $rowStatus
            }
        }
    }

    $totalRowCount      = $allRows.Count
    $overallStatusLabel = if ($passed) { 'Pass' } else { 'Fail' }
    $summaryLine = if ($passed) {
        "**Status: $overallStatusLabel** — Tenant uses Intune RBAC delegation; $qualifyingCount RBAC assignment(s) with members exist."
    }
    else {
        "**Status: $overallStatusLabel** — No Intune RBAC role assignments with members exist. Tenant relies only on full Intune Administrator access."
    }

    if ($totalRowCount -gt 0) {
        $displayedRows = if ($totalRowCount -gt $maxRows) { $allRows | Select-Object -First $maxRows } else { $allRows }
        $tableRows = ''
        foreach ($row in $displayedRows) {
            $tableRows += "| $($row.RoleSource) | $($row.RoleName) | $($row.AssignmentName) | $($row.MemberCount) | $($row.Scope) | $($row.RoleType) | $($row.RowStatus) |`n"
        }
        if ($totalRowCount -gt $maxRows) {
            $remaining  = $totalRowCount - $maxRows
            $tableRows += "| ... and $remaining more assignments | | | | | | |`n"
        }

        $formatTemplate = @'

## [Intune Administrator and RBAC role assignments]({1})

{2}

| Role source | Role name | Assignment name | Member count | Scope | Role type | Status |
| :---------- | :-------- | :-------------- | :----------- | :---- | :-------- | :----- |
{0}
'@
        $mdInfo = $formatTemplate -f $tableRows, $portalLink, $summaryLine
    }
    else {
        $mdInfo = @"

## [Intune Administrator and RBAC role assignments]($portalLink)

$summaryLine

No role assignments found.

"@
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51021'
        Title  = 'Least privilege Intune RBAC roles are assigned instead of relying only on full Intune Administrator'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
