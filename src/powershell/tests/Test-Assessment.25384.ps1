<#
.SYNOPSIS
    Checks if Application Administrator rights are constrained to specific Private Access apps.

.DESCRIPTION
    This test validates that Application Administrator role assignments are scoped to specific
    applications rather than tenant-wide, and that assignments follow least privilege principles.

.NOTES
    Test ID: 25384
    Category: Access control
    Required API: roleManagement/directory (beta)
#>

function Test-Assessment-25384 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Network',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 25384,
    	Title = 'Application admin rights are constrained to specific Private Access apps, not tenant-wide',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Administrator role assignments'
    Write-ZtProgress -Activity $activity -Status 'Getting role definition'

    # Query 1: Get Application Administrator role definition
    $appAdminRoleId = Get-ZtRoleInfo -RoleName 'ApplicationAdministrator'

    Write-ZtProgress -Activity $activity -Status 'Getting role assignments with principal details'

    # Query 2: Get Application Administrator role assignments with expanded principal (no nested $select)
    $assignments = Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '$appAdminRoleId'&`$expand=principal" -ApiVersion beta

    # Default to empty array if no assignments found
    $assignments = $assignments ?? @()

    # Collect scoped IDs from assignments for Q3 resolution
    $spIds = @()
    $appIds = @()
    foreach ($assignment in $assignments) {
        if ($assignment.directoryScopeId -ne '/') {
            $scopeId = $assignment.directoryScopeId -replace '^/', ''
            if ($scopeId -match '^servicePrincipals/(.+)') {
                $spIds += $Matches[1]
            } elseif ($scopeId -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
                $appIds += $scopeId
            }
        }
    }

    Write-ZtProgress -Activity $activity -Status 'Resolving scoped service principals and applications'

    # Query 3: Resolve scoped service principals and applications
    $spLookup = @{}
    $appLookup = @{}

    # Fetch service principals referenced in scoped assignments
    $uniqueSpIds = $spIds | Select-Object -Unique

    if ($uniqueSpIds) {
        $sps = Invoke-ZtGraphBatchRequest -Path "servicePrincipals/{0}?`$select=id,displayName,appId,appOwnerOrganizationId" -ArgumentList $uniqueSpIds -ApiVersion beta
        foreach ($sp in $sps) { $spLookup[$sp.id] = $sp }
    }

    # Fetch applications directly referenced in scoped assignments (app registrations)
    $uniqueAppIds = $appIds | Select-Object -Unique

       if ($uniqueAppIds) {
        $apps = Invoke-ZtGraphBatchRequest -Path "applications/{0}?`$select=id,displayName,appId,tags,appOwnerOrganizationId" -ArgumentList $uniqueAppIds -ApiVersion beta
        foreach ($app in $apps) {
            $appLookup[$app.id] = $app
            if ($app.appId) { $appLookup[$app.appId] = $app }
        }
    }

    Write-ZtProgress -Activity $activity -Status 'Detecting Private Access and Quick Access apps'

    # Query 4: Detect Private Access / Quick Access apps via tags (bulk fetch)
    $paQaAppLookup = @{}
    try {
        $paQuickAccessApps = Invoke-ZtGraphRequest -RelativeUri "applications" -Filter "(tags/any(t: t eq 'PrivateAccessNonWebApplication') or tags/any(t: t eq 'NetworkAccessQuickAccessApplication'))" -Select 'id,displayName,appId,tags' -ApiVersion beta
        foreach ($app in $paQuickAccessApps) {
            if ($app.appId) { $paQaAppLookup[$app.appId] = $app }
            if ($app.id) { $paQaAppLookup[$app.id] = $app }
        }
    } catch {
        Write-PSFMessage "Unable to query Private Access/Quick Access apps by tags" -Level Verbose
    }

    # Fetch application details for service principals from Q3 (if not already in PA/QA lookup)
    $spAppIds = @($spLookup.Values | Where-Object { $_.appId } | ForEach-Object { $_.appId }) | Select-Object -Unique
    $appIdsToFetch = $spAppIds | Where-Object { -not $paQaAppLookup.ContainsKey($_) -and -not $appLookup.ContainsKey($_) }

    if ($appIdsToFetch) {
        $apps = Invoke-ZtGraphBatchRequest -Path "applications?`$filter=appId eq '{0}'&`$select=id,displayName,appId,tags,appOwnerOrganizationId" -ArgumentList $appIdsToFetch -ApiVersion beta
        foreach ($app in $apps) {
            if ($app) {
                $appLookup[$app.id] = $app
                $appLookup[$app.appId] = $app
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $true
    $tenantWideAssignments = @()
    $scopedAssignments = @()
    $problematicAssignments = @()
    $warnings = @()

    foreach ($assignment in $assignments) {
        $principalType = if ($assignment.principal.'@odata.type') {
            $assignment.principal.'@odata.type' -replace '#microsoft.graph.', ''
        } else { 'unknown' }

        $assignmentInfo = [PSCustomObject]@{
            DirectoryScopeId    = $assignment.directoryScopeId
            PrincipalId         = $assignment.principalId
            PrincipalDisplayName = $assignment.principal.displayName
            PrincipalUPN        = $assignment.principal.userPrincipalName
            PrincipalType       = $principalType
            UserType            = $assignment.principal.userType
            AccountEnabled      = $assignment.principal.accountEnabled
            AppDisplayName      = ''
            AppId               = ''
            IsPAApp             = $false
        }

        if ($assignment.directoryScopeId -eq '/') {
            $tenantWideAssignments += $assignmentInfo
            $passed = $false
        } else {
            $scopeId = $assignment.directoryScopeId -replace '^/', ''
            if ($scopeId -match '^servicePrincipals/(.+)') {
                $spId = $Matches[1]
                if ($spLookup.ContainsKey($spId)) {
                    $sp = $spLookup[$spId]
                    $assignmentInfo.AppDisplayName = $sp.displayName
                    $assignmentInfo.AppId = $sp.appId
                    $app = $paQaAppLookup[$sp.appId] ?? $appLookup[$sp.appId]
                    if ($app) {
                        $assignmentInfo.IsPAApp = ($app.tags -contains 'PrivateAccessNonWebApplication') -or ($app.tags -contains 'NetworkAccessQuickAccessApplication')
                    }
                }
            } else {
                $app = $paQaAppLookup[$scopeId] ?? $appLookup[$scopeId]
                if ($app) {
                    $assignmentInfo.AppDisplayName = $app.displayName
                    $assignmentInfo.AppId = $app.appId
                    $assignmentInfo.IsPAApp = ($app.tags -contains 'PrivateAccessNonWebApplication') -or ($app.tags -contains 'NetworkAccessQuickAccessApplication')
                }
            }
            $scopedAssignments += $assignmentInfo
        }

        if ($principalType -in @('group', 'servicePrincipal') -or $assignment.principal.userType -eq 'Guest') {
            $problematicAssignments += $assignmentInfo
            $passed = $false
        }
    }

    if ($assignments.Count -gt 5) {
        $warnings += "Assignment count ($($assignments.Count)) exceeds recommended threshold of 5"
    }

    $scopedNonPACount = ($scopedAssignments | Where-Object { -not $_.IsPAApp -and $_.AppDisplayName }).Count
    if ($scopedNonPACount -gt 0) {
        $warnings += "$scopedNonPACount scoped assignment(s) to apps that are not confirmed as Private Access or Quick Access apps"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Summary Section
    $mdInfo += "`n## Summary`n`n"
    $mdInfo += "| Metric | Count |`n"
    $mdInfo += "| :--- | ---: |`n"
    $mdInfo += "| Total Assignments | $($assignments.Count) |`n"
    $mdInfo += "| Tenant-Wide Assignments | $($tenantWideAssignments.Count) |`n"
    $mdInfo += "| Scoped Assignments | $($scopedAssignments.Count) |`n"
    $mdInfo += "| Problematic Assignments | $($problematicAssignments.Count) |`n`n"

    # Application Administrator Assignments
    $mdInfo += "`n## Application Administrator Assignments:`n`n"
    $mdInfo += "- Count: $($assignments.Count)`n`n"

    if ($assignments.Count -gt 0) {
        $mdInfo += "| DirectoryScopeId | Principal DisplayName | UPN | AccountEnabled | Type | User Type |`n"
        $mdInfo += "| :--- | :--- | :--- | :---: | :--- | :--- |`n"
        foreach ($rawA in $assignments) {
            $scope = $rawA.directoryScopeId
            $displayName = $rawA.principal.displayName
            $upn = $rawA.principal.userPrincipalName
            $acctEnabled = if ($null -ne $rawA.principal.accountEnabled) { $rawA.principal.accountEnabled } else { '' }
            $pType = if ($rawA.principal.'@odata.type') { $rawA.principal.'@odata.type' -replace '#microsoft.graph.', '' } else { 'unknown' }
            $uType = $rawA.principal.userType
            $mdInfo += "| $(Get-SafeMarkdown -Text $scope) | $(Get-SafeMarkdown -Text $displayName) | $upn | $acctEnabled | $pType | $uType |`n"
        }
        $mdInfo += "`n"
    }

    # Build map of all discovered apps for display
    $scopedAppsMap = @{ }
    foreach ($app in $paQaAppLookup.Values) {
        if ($app.appId) {
            $scopedAppsMap[$app.appId] = $app
        } elseif ($app.id) {
            $scopedAppsMap[$app.id] = $app
        }
    }
    foreach ($app in $appLookup.Values) {
        if ($app.appId) {
            $scopedAppsMap[$app.appId] = $app
        } elseif ($app.id) {
            $scopedAppsMap[$app.id] = $app
        }
    }
    foreach ($sp in $spLookup.Values) {
        if ($sp.appId) {
            if (-not $scopedAppsMap.ContainsKey($sp.appId)) {
                if ($appLookup.ContainsKey($sp.appId)) {
                    $scopedAppsMap[$sp.appId] = $appLookup[$sp.appId]
                } else {
                    $scopedAppsMap[$sp.appId] = [PSCustomObject]@{
                        displayName = $sp.displayName
                        appId = $sp.appId
                        id = $null
                        tags = @()
                    }
                }
            }
        }
    }

    # Scoped Apps section
    if ($scopedAppsMap.Count -gt 0) {
        $mdInfo += "`n## Scoped Apps:`n`n"
        $mdInfo += "| App DisplayName | appId / servicePrincipalId | Tags (includes PA/QA?) |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($app in $scopedAppsMap.Values) {
            $display = if ($app.displayName) {
                $(Get-SafeMarkdown -Text $app.displayName)
            } else {
                'Unknown'
            }
            $id = if ($app.appId) {
                $app.appId
            } elseif ($app.id) {
                $app.id
            } else {
                ''
            }
            $tags = if ($app.tags) {
                ($app.tags -join ', ')
            } else {
                ''
            }
            $paqa = if ($app.tags -and (($app.tags -contains 'PrivateAccessNonWebApplication') -or ($app.tags -contains 'NetworkAccessQuickAccessApplication'))) {
                '✅'
            } else {
                '❌'
            }
            $mdInfo += "| $display | $id | $tags $paqa |`n"
        }
        $mdInfo += "`n"
    }

    # Tenant-Wide Assignments
    if ($tenantWideAssignments.Count -gt 0) {
        $mdInfo += "`n## ❌ Tenant-Wide Assignments`n`n"
        $mdInfo += "The following Application Administrator assignments have tenant-wide scope and should be constrained:`n`n"
        $mdInfo += "| Principal | Type | User Type | Scope |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($a in $tenantWideAssignments) {
            $principalName = if ($a.PrincipalUPN) { $a.PrincipalUPN } else { $a.PrincipalDisplayName }
            $mdInfo += "| $(Get-SafeMarkdown -Text $principalName) | $($a.PrincipalType) | $($a.UserType) | Tenant-wide (/) |`n"
        }
        $mdInfo += "`n"
    }

    # Problematic Assignments
    if ($problematicAssignments.Count -gt 0) {
        $mdInfo += "`n## ❌ Problematic Principal Assignments`n`n"
        $mdInfo += "The following assignments use groups, service principals, or guest users:`n`n"
        $mdInfo += "| Principal | Type | User Type | Scope |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($a in $problematicAssignments) {
            $principalName = if ($a.PrincipalUPN) { $a.PrincipalUPN } else { $a.PrincipalDisplayName }
            $scope = if ($a.DirectoryScopeId -eq '/') { 'Tenant-wide (/)' } else { 'Scoped' }
            $mdInfo += "| $(Get-SafeMarkdown -Text $principalName) | $($a.PrincipalType) | $($a.UserType) | $scope |`n"
        }
        $mdInfo += "`n"
    }

    # Scoped Assignments
    if ($scopedAssignments.Count -gt 0) {
        $mdInfo += "`n## ✅ Scoped Assignments`n`n"
        $mdInfo += "The following Application Administrator assignments are scoped to specific applications:`n`n"
        $mdInfo += "| Principal | Type | Application | PA/QA App |`n"
        $mdInfo += "| :--- | :--- | :--- | :---: |`n"
        foreach ($a in $scopedAssignments | Sort-Object PrincipalDisplayName) {
            $principalName = if ($a.PrincipalUPN) { $a.PrincipalUPN } else { $a.PrincipalDisplayName }
            $appName = if ($a.AppDisplayName) { $a.AppDisplayName } else { 'Unknown app' }
            $paIcon = if ($a.IsPAApp) { '✅' } else { '❌' }
            $mdInfo += "| $(Get-SafeMarkdown -Text $principalName) | $($a.PrincipalType) | $(Get-SafeMarkdown -Text $appName) | $paIcon |`n"
        }
        $mdInfo += "`n"
    }

    # Warnings
    if ($warnings.Count -gt 0) {
        $mdInfo += "`n## ⚠️ Warnings`n`n"
        foreach ($warning in $warnings) {
            $mdInfo += "- $warning`n"
        }
        $mdInfo += "`n"
    }

    # Portal Link
    $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AllRolesBlade"
    $portalLinkText = Get-SafeMarkdown -Text "View in Entra Portal: Roles and administrators"
    $mdInfo += "`n[$portalLinkText]($portalLink)"

    $testResultMarkdown = $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25384'
        Title  = 'Application admin rights are constrained to specific Private Access apps, not tenant-wide'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
