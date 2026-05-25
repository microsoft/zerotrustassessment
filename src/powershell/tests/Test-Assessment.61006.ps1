<#
.SYNOPSIS
    Validates that AI administrative roles in Microsoft Entra have at least one assigned principal.

.DESCRIPTION
    This test validates that every Microsoft Entra administrative role identified as an AI
    administrative scope has at least one assigned principal (active or PIM-eligible) at tenant
    scope, so each slice of the AI control plane has an accountable owner.

.NOTES
    Test ID: 61006
    Category: AI Authentication & Access
    Pillar: AI
    Data source: Local ZTA database tables RoleDefinition, RoleAssignment,
        RoleAssignmentScheduleInstance, RoleEligibilityScheduleInstance, and their
        expanded group-membership companion tables (*Group), which are populated from
        Microsoft Graph roleManagement/directory by the ZTA tenant export.
#>

function Test-Assessment-61006 {
    [ZtTest(
        Category = 'AI Authentication & Access',
        ImplementationCost = 'Low',
        CompatibleLicense = ('AAD_BASIC', 'AAD_PREMIUM'),
        Service = ('Graph'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 61006,
        Title = 'AI administrative roles have assigned principals',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $nl = [Environment]::NewLine
    $activity = 'Checking AI administrative roles for assigned principals'
    Write-ZtProgress -Activity $activity -Status 'Enumerating AI admin roles'

    # In-scope roles - workshop guidance AI_149. Reader tier (Global Reader, Security Reader)
    # downgrades to Investigate instead of Fail at the tenant level per spec.
    # The canonical AI control-plane role catalog lives in
    # private/tests-shared/Get-ZtAiAdminRoleDefinitions.ps1 so it can be reused
    # by future AI_149-family checks.
    $inScopeRoles = Get-ZtAiAdminRoleDefinitions

    $roleIdInClause = ($inScopeRoles | ForEach-Object { "'$($_.Id)'" }) -join ', '

    # Discover which exported tables are present (varies by tenant license tier).
    Write-ZtProgress -Activity $activity -Status 'Inspecting database schema'
    $existingTables = @(Invoke-DatabaseQuery -Database $Database -Sql "SELECT table_name FROM information_schema.tables WHERE table_schema = 'main'" |
        Select-Object -ExpandProperty table_name)

    # Q1 equivalent: which role definitions are present in this tenant / cloud / SKU.
    Write-ZtProgress -Activity $activity -Status 'Loading role definitions'
    $presentRoleIds = @()
    $roleDefinitionTableMissing = $false
    if ($existingTables -contains 'RoleDefinition') {
        $defSql = "SELECT cast(id AS varchar) AS id FROM main.""RoleDefinition"" WHERE id IN ($roleIdInClause)"
        $presentRoleIds = @(Invoke-DatabaseQuery -Database $Database -Sql $defSql | Select-Object -ExpandProperty id)
    }
    else {
        $roleDefinitionTableMissing = $true
    }

    # Build the direct-assignment UNION over only the tables that exist for this tenant.
    # assignmentType = 'Assigned' on RoleAssignmentScheduleInstance excludes currently-active
    # PIM activations, so an eligible-then-activated user is not double-counted as active.
    $assignmentSelects = @()
    if ($existingTables -contains 'RoleAssignmentScheduleInstance') {
        $assignmentSelects += @"
SELECT cast(roleDefinitionId AS varchar)        AS roleDefinitionId,
       cast(directoryScopeId AS varchar)        AS directoryScopeId,
       cast(principalId       AS varchar)       AS principalId,
       cast(principal."@odata.type" AS varchar) AS principalOdataType,
       'Active'                                 AS source
FROM main."RoleAssignmentScheduleInstance"
WHERE roleDefinitionId IN ($roleIdInClause)
  AND assignmentType = 'Assigned'
"@
    }
    if ($existingTables -contains 'RoleAssignment') {
        $assignmentSelects += @"
SELECT cast(roleDefinitionId AS varchar)        AS roleDefinitionId,
       cast(directoryScopeId AS varchar)        AS directoryScopeId,
       cast(principalId       AS varchar)       AS principalId,
       cast(principal."@odata.type" AS varchar) AS principalOdataType,
       'ActiveLegacy'                           AS source
FROM main."RoleAssignment"
WHERE roleDefinitionId IN ($roleIdInClause)
"@
    }
    if ($existingTables -contains 'RoleEligibilityScheduleInstance') {
        $assignmentSelects += @"
SELECT cast(roleDefinitionId AS varchar)        AS roleDefinitionId,
       cast(directoryScopeId AS varchar)        AS directoryScopeId,
       cast(principalId       AS varchar)       AS principalId,
       cast(principal."@odata.type" AS varchar) AS principalOdataType,
       'Eligible'                               AS source
FROM main."RoleEligibilityScheduleInstance"
WHERE roleDefinitionId IN ($roleIdInClause)
"@
    }

    $assignments = @()
    if ($assignmentSelects.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Loading role assignments'
        $assignmentSql = $assignmentSelects -join "$nl UNION ALL $nl"
        $assignments = @(Invoke-DatabaseQuery -Database $Database -Sql $assignmentSql)
    }

    # Build the set of non-empty groups by (roleDefinitionId, groupId). Groups with zero
    # expanded transitive members do not appear in the *Group tables and therefore do not
    # satisfy the "named principal" requirement.
    $nonEmptyGroupSelects = @()
    if ($existingTables -contains 'RoleAssignmentScheduleInstanceGroup') {
        $nonEmptyGroupSelects += @"
SELECT DISTINCT cast(roleDefinitionId AS varchar)  AS roleDefinitionId,
                cast(privilegedGroupId AS varchar) AS groupId
FROM main."RoleAssignmentScheduleInstanceGroup"
WHERE roleDefinitionId IN ($roleIdInClause)
"@
    }
    if ($existingTables -contains 'RoleEligibilityScheduleInstanceGroup') {
        $nonEmptyGroupSelects += @"
SELECT DISTINCT cast(roleDefinitionId AS varchar)  AS roleDefinitionId,
                cast(privilegedGroupId AS varchar) AS groupId
FROM main."RoleEligibilityScheduleInstanceGroup"
WHERE roleDefinitionId IN ($roleIdInClause)
"@
    }
    if ($existingTables -contains 'RoleAssignmentGroup') {
        $nonEmptyGroupSelects += @"
SELECT DISTINCT cast(roleDefinitionId AS varchar)  AS roleDefinitionId,
                cast(privilegedGroupId AS varchar) AS groupId
FROM main."RoleAssignmentGroup"
WHERE roleDefinitionId IN ($roleIdInClause)
"@
    }

    $nonEmptyGroupKeys = @{}
    if ($nonEmptyGroupSelects.Count -gt 0) {
        $groupSql = $nonEmptyGroupSelects -join "$nl UNION $nl"
        $groupRows = @(Invoke-DatabaseQuery -Database $Database -Sql $groupSql)
        foreach ($g in $groupRows) {
            $nonEmptyGroupKeys["$($g.roleDefinitionId)|$($g.groupId)"] = $true
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    Write-ZtProgress -Activity $activity -Status 'Evaluating per-role outcomes'

    $perRole = @()
    foreach ($role in $inScopeRoles) {
        $roleId = $role.Id

        if ($presentRoleIds -notcontains $roleId) {
            $perRole += [pscustomobject]@{
                Name            = $role.Name
                Id              = $roleId
                Tier            = $role.Tier
                Outcome         = 'NotInScope'
                TenantCount     = 0
                RestrictedCount = 0
            }
            continue
        }

        $rows = @($assignments | Where-Object { $_.roleDefinitionId -eq $roleId })

        $qualifyingRows = @(
            foreach ($r in $rows) {
                $isGroup = $r.principalOdataType -eq '#microsoft.graph.group'
                if ($isGroup -and -not $nonEmptyGroupKeys.ContainsKey("$roleId|$($r.principalId)")) {
                    continue
                }
                $r
            }
        )

        $uniqueQualifying     = @($qualifyingRows | Sort-Object -Property principalId, directoryScopeId -Unique)
        $tenantQualifying     = @($uniqueQualifying | Where-Object { $_.directoryScopeId -eq '/' })
        $restrictedQualifying = @($uniqueQualifying | Where-Object { $_.directoryScopeId -ne '/' })

        if ($tenantQualifying.Count -gt 0) {
            $outcome = 'Pass'
        }
        elseif ($restrictedQualifying.Count -gt 0) {
            $outcome = 'Investigate'
        }
        else {
            $outcome = 'Fail'
        }

        $perRole += [pscustomobject]@{
            Name            = $role.Name
            Id              = $roleId
            Tier            = $role.Tier
            Outcome         = $outcome
            TenantCount     = $tenantQualifying.Count
            RestrictedCount = $restrictedQualifying.Count
        }
    }

    $evaluated   = @($perRole   | Where-Object { $_.Outcome -ne 'NotInScope' })
    $adminFails  = @($evaluated | Where-Object { $_.Tier -eq 'Admin'  -and $_.Outcome -eq 'Fail' })
    $readerFails = @($evaluated | Where-Object { $_.Tier -eq 'Reader' -and $_.Outcome -eq 'Fail' })
    $investig    = @($evaluated | Where-Object { $_.Outcome -eq 'Investigate' })

    if ($roleDefinitionTableMissing) {
        $passed       = $false
        $customStatus = 'Investigate'
    }
    elseif ($adminFails.Count -gt 0) {
        $passed       = $false
        $customStatus = $null
    }
    elseif ($investig.Count -gt 0 -or $readerFails.Count -gt 0) {
        $passed       = $false
        $customStatus = 'Investigate'
    }
    elseif ($evaluated.Count -eq 0) {
        $passed       = $false
        $customStatus = 'Investigate'
    }
    else {
        $passed       = $true
        $customStatus = $null
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($roleDefinitionTableMissing) {
        $headline = '⚠️ Cannot evaluate AI administrative roles: the required `RoleDefinition` export table is missing from the ZTA database. Re-run the tenant export and try again.'
    }
    elseif ($evaluated.Count -eq 0) {
        $headline = '⚠️ None of the in-scope AI administrative role definitions were found in this tenant''s export. No roles were evaluated. Verify the export covers role definitions for this cloud/SKU.'
    }
    elseif ($passed) {
        $headline = '✅ Every AI administrative role in Microsoft Entra has at least one tenant-scoped assigned principal. (This check evaluates Microsoft Entra directory roles only; administrators granted through workload-native role systems — Microsoft Purview role groups, Defender XDR custom roles, Power Platform / Dataverse roles, SharePoint site permissions, Copilot Studio maker permissions — are out of scope.)'
    }
    elseif ($customStatus -eq 'Investigate') {
        $headline = '⚠️ One or more AI administrative roles are assigned only at administrative-unit or app scope, with no tenant-wide principal. Confirm this matches your delegated-administration model. Reader-tier roles (`Global Reader`, `Security Reader`) with no assigned principal also surface here.'
    }
    else {
        $headline = '❌ One or more AI administrative roles in Microsoft Entra have no assigned principal (or only empty role-assignable groups).'
    }

    $testResultMarkdown = $headline + $nl + $nl + '%TestResult%'

    $notInScopeCount = @($perRole   | Where-Object { $_.Outcome -eq 'NotInScope' }).Count
    $passCount       = @($perRole   | Where-Object { $_.Outcome -eq 'Pass' }).Count
    $failCount       = @($evaluated | Where-Object { $_.Outcome -eq 'Fail' }).Count

    $mdLines = @(
        ''
        '**AI administrative role evaluation summary:**'
        ''
        "* In-scope roles: $($inScopeRoles.Count)"
        "* Evaluated (role definition present in tenant): $($evaluated.Count)"
        "* Not evaluated (role definition missing in this cloud/SKU): $notInScopeCount"
        "* Pass: $passCount"
        "* Investigate: $($investig.Count)"
        "* Fail: $failCount"
    )

    $nonPass = @($evaluated | Where-Object { $_.Outcome -ne 'Pass' } | Sort-Object Outcome, Name)
    if ($nonPass.Count -gt 0) {
        $tableLines = @(
            ''
            ''
            '## AI administrative roles with no tenant-scoped assigned principal'
            ''
            '| Role | Tenant-scoped principals | Restricted-scope principals | Tier | Outcome |'
            '| :--- | :----------------------- | :-------------------------- | :--- | :------ |'
        )
        foreach ($r in $nonPass) {
            $roleNameEncoded = [System.Uri]::EscapeDataString($r.Name)
            $rolePortalUrl   = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RoleMenuBlade/~/AllAssignments' +
                               "/objectId/$($r.Id)" +
                               "/roleName/$roleNameEncoded" +
                               "/roleTemplateId/$($r.Id)" +
                               '/adminUnitObjectId/' +
                               '/customRole~/false' +
                               '/resourceScope/%2F'
            $nameLink        = "[$(Get-SafeMarkdown -Text $r.Name)]($rolePortalUrl)"
            $outcomeIcon = switch ($r.Outcome) {
                'Investigate' { '⚠️ Investigate' }
                'Fail'        { '❌ Fail' }
                default       { $r.Outcome }
            }
            $tableLines += "| $nameLink | $($r.TenantCount) | $($r.RestrictedCount) | $($r.Tier) | $outcomeIcon |"
        }
        $mdLines += $tableLines
    }

    $mdInfo = ($mdLines -join $nl) + $nl

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61006'
        Title  = 'AI administrative roles have assigned principals'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
