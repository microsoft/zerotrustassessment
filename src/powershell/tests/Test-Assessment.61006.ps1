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
    $inScopeRoles = @(
        @{ Name = 'AI Administrator';                   Id = 'd2562ede-74db-457e-a7b6-544e236ebb61'; Tier = 'Admin'  }
        @{ Name = 'Agent ID Administrator';             Id = 'db506228-d27e-4b7d-95e5-295956d6615f'; Tier = 'Admin'  }
        @{ Name = 'Agent ID Developer';                 Id = 'adb2368d-a9be-41b5-8667-d96778e081b0'; Tier = 'Admin'  }
        @{ Name = 'Agent Registry Administrator';       Id = '6b942400-691f-4bf0-9d12-d8a254a2baf5'; Tier = 'Admin'  }
        @{ Name = 'Application Administrator';          Id = '9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3'; Tier = 'Admin'  }
        @{ Name = 'Compliance Administrator';           Id = '17315797-102d-40b4-93e0-432062caca18'; Tier = 'Admin'  }
        @{ Name = 'Compliance Data Administrator';      Id = 'e6d1a23a-da11-4be4-9570-befc86d067a7'; Tier = 'Admin'  }
        @{ Name = 'Conditional Access Administrator';   Id = 'b1be1c3e-b65d-4f19-8427-f6fa0d97feb9'; Tier = 'Admin'  }
        @{ Name = 'Global Reader';                      Id = 'f2ef992c-3afb-46b9-b7cf-a126ee74c451'; Tier = 'Reader' }
        @{ Name = 'Global Secure Access Administrator'; Id = 'ac434307-12b9-4fa1-a708-88bf58caabc1'; Tier = 'Admin'  }
        @{ Name = 'Identity Governance Administrator';  Id = '45d8d3c5-c802-45c6-b32a-1d70b5e1e86e'; Tier = 'Admin'  }
        @{ Name = 'Intune Administrator';               Id = '3a2c62db-5318-420d-8d74-23affee5d9d5'; Tier = 'Admin'  }
        @{ Name = 'Power Platform Administrator';       Id = '11648597-926c-4cf3-9c36-bcebb0ba8dcc'; Tier = 'Admin'  }
        @{ Name = 'Security Administrator';             Id = '194ae4cb-b126-40b2-bd5b-6091b380977d'; Tier = 'Admin'  }
        @{ Name = 'Security Operator';                  Id = '5f2222b1-57c3-48ba-8ad5-d4759f1fde6f'; Tier = 'Admin'  }
        @{ Name = 'Security Reader';                    Id = '5d6b6bb7-de71-4623-b4af-96380a352509'; Tier = 'Reader' }
        @{ Name = 'SharePoint Administrator';           Id = 'f28a1f50-f6e7-4571-818b-6a12f2af6b6c'; Tier = 'Admin'  }
    )

    $roleIdInClause = ($inScopeRoles | ForEach-Object { "'$($_.Id)'" }) -join ', '

    # Discover which exported tables are present (varies by tenant license tier).
    Write-ZtProgress -Activity $activity -Status 'Inspecting database schema'
    $existingTables = @(Invoke-DatabaseQuery -Database $Database -Sql "SELECT table_name FROM information_schema.tables WHERE table_schema = 'main'" |
        Select-Object -ExpandProperty table_name)

    # Q1 equivalent: which role definitions are present in this tenant / cloud / SKU.
    Write-ZtProgress -Activity $activity -Status 'Loading role definitions'
    $presentRoleIds = @()
    if ($existingTables -contains 'RoleDefinition') {
        $defSql = "SELECT cast(id AS varchar) AS id FROM main.""RoleDefinition"" WHERE id IN ($roleIdInClause)"
        $presentRoleIds = @(Invoke-DatabaseQuery -Database $Database -Sql $defSql | Select-Object -ExpandProperty id)
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

    if ($adminFails.Count -gt 0) {
        $passed       = $false
        $customStatus = $null
    }
    elseif ($investig.Count -gt 0 -or $readerFails.Count -gt 0) {
        $passed       = $false
        $customStatus = 'Investigate'
    }
    else {
        $passed       = $true
        $customStatus = $null
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($passed) {
        $headline = '✅ Every AI administrative role in Microsoft Entra has at least one tenant-scoped assigned principal.'
    }
    elseif ($customStatus -eq 'Investigate') {
        $headline = '🟡 One or more AI administrative roles have assignments only at administrative-unit or app scope, or a reader-tier role has no assigned principal. Confirm this matches your delegated-administration model.'
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
                'Investigate' { '🟡 Investigate' }
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
