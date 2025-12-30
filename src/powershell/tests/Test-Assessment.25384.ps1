<#
.SYNOPSIS
    Checks if Application Administrator rights are constrained to specific Private Access apps.

.DESCRIPTION
    This test validates that Application Administrator role assignments are scoped to specific
    applications rather than tenant-wide, and that assignments follow least privilege principles.

.NOTES
    Test ID: 25384
    Category: Access control
    Required API: roleManagement/directory (v1.0)
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
    $appAdminRole = Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/roleDefinitions" -Filter "displayName eq 'Application Administrator'" -ApiVersion beta

    if (-not $appAdminRole) {
        Add-ZtTestResultDetail -TestId '25384' -Status $false -Result "Unable to retrieve Application Administrator role definition."
        return
    }

    $appAdminRoleId = $appAdminRole.id
    Write-ZtProgress -Activity $activity -Status 'Getting role assignments with principal details'

    # Query 2: Get Application Administrator role assignments with expanded principal (no nested $select)
    $assignments = Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '$appAdminRoleId'&`$expand=principal" -ApiVersion v1.0

    # Default to empty array if no assignments found
    $assignments = $assignments ?? @()

    Write-ZtProgress -Activity $activity -Status 'Resolving scoped applications'

    # Query 4: Bulk fetch all Private Access and Quick Access apps by tags
    $paQaAppLookup = @{}
    try {
        $paQuickAccessApps = Invoke-ZtGraphRequest -RelativeUri "applications" -Filter "(tags/any(t: t eq 'PrivateAccessNonWebApplication') or tags/any(t: t eq 'NetworkAccessQuickAccessApplication'))" -Select 'id,displayName,appId,tags' -ApiVersion v1.0
        foreach ($app in $paQuickAccessApps) {
            if ($app.appId) { $paQaAppLookup[$app.appId] = $app }
            if ($app.id) { $paQaAppLookup[$app.id] = $app }
        }
    } catch {
        Write-PSFMessage "Unable to query Private Access/Quick Access apps by tags" -Level Verbose
    }

    # Collect scoped IDs in single pass
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

    # Consolidate batch fetch logic for service principals and applications
    $spLookup = @{}
    $appLookup = @{}

    # Batch fetch service principals
    $uniqueSpIds = $spIds | Select-Object -Unique
    if ($uniqueSpIds.Count -gt 0) {
        $uniqueSpIds | ForEach-Object -Process {
            try {
                $sp = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$_" -Select 'id,displayName,appId' -ApiVersion v1.0
                if ($sp) { $spLookup[$sp.id] = $sp }
            } catch {
                Write-PSFMessage "Unable to resolve service principal $_" -Level Verbose
            }
        }
    }

    # Collect all app IDs to fetch (from scoped apps + service principal appIds)
    $allAppIds = @($appIds) + @($spLookup.Values | Where-Object { $_.appId } | ForEach-Object { $_.appId }) | Select-Object -Unique
    $appIdsToFetch = $allAppIds | Where-Object { -not $paQaAppLookup.ContainsKey($_) }

    if ($appIdsToFetch.Count -gt 0) {
        $appIdsToFetch | ForEach-Object -Process {
            try {
                $app = Invoke-ZtGraphRequest -RelativeUri "applications/$_" -Select 'id,displayName,appId,tags' -ApiVersion v1.0
                if ($app) {
                    $appLookup[$app.id] = $app
                    $appLookup[$app.appId] = $app
                }
            } catch {
                Write-PSFMessage "Unable to resolve application $_" -Level Verbose
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
    $mdInfo = [System.Text.StringBuilder]::new()

    # Summary Section
    [void]$mdInfo.AppendLine("`n## Summary`n")
    [void]$mdInfo.AppendLine("| Metric | Count |")
    [void]$mdInfo.AppendLine("| :--- | ---: |")
    [void]$mdInfo.AppendLine("| Total Assignments | $($assignments.Count) |")
    [void]$mdInfo.AppendLine("| Tenant-Wide Assignments | $($tenantWideAssignments.Count) |")
    [void]$mdInfo.AppendLine("| Scoped Assignments | $($scopedAssignments.Count) |")
    [void]$mdInfo.AppendLine("| Problematic Assignments | $($problematicAssignments.Count) |`n")

    # Application Administrator Assignments (Q2) - count and per-assignment details
    [void]$mdInfo.AppendLine("`n## Application Administrator Assignments:`n")
    [void]$mdInfo.AppendLine("- Count: $($assignments.Count)`n")
    if ($assignments.Count -gt 0) {
        [void]$mdInfo.AppendLine("| DirectoryScopeId | Principal DisplayName | UPN | AccountEnabled | Type | User Type |")
        [void]$mdInfo.AppendLine("| :--- | :--- | :--- | :---: | :--- | :--- |")
        foreach ($rawA in $assignments) {
            $scope = $rawA.directoryScopeId
            $displayName = $rawA.principal.displayName
            $upn = $rawA.principal.userPrincipalName
            $acctEnabled = if ($null -ne $rawA.principal.accountEnabled) { $rawA.principal.accountEnabled } else { '' }
            $pType = if ($rawA.principal.'@odata.type') { $rawA.principal.'@odata.type' -replace '#microsoft.graph.', '' } else { 'unknown' }
            $uType = $rawA.principal.userType
            [void]$mdInfo.AppendLine("| $(Get-SafeMarkdown -Text $scope) | $(Get-SafeMarkdown -Text $displayName) | $upn | $acctEnabled | $pType | $uType |")
        }
        [void]$mdInfo.AppendLine()
    }

    # Scoped Apps (Q3/Q4, optional): discovered apps and tags
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

    if ($scopedAppsMap.Count -gt 0) {
        [void]$mdInfo.AppendLine("`n## Scoped Apps:`n")
        [void]$mdInfo.AppendLine("| App DisplayName | appId / servicePrincipalId | Tags (includes PA/QA?) |")
        [void]$mdInfo.AppendLine("| :--- | :--- | :--- |")
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
            [void]$mdInfo.AppendLine("| $display | $id | $tags $paqa |")
        }
        [void]$mdInfo.AppendLine()
    }

    # Tenant-Wide Assignments
    if ($tenantWideAssignments.Count -gt 0) {
        [void]$mdInfo.AppendLine("`n## ❌ Tenant-Wide Assignments`n")
        [void]$mdInfo.AppendLine("The following Application Administrator assignments have tenant-wide scope and should be constrained:`n")
        [void]$mdInfo.AppendLine("| Principal | Type | User Type | Scope |")
        [void]$mdInfo.AppendLine("| :--- | :--- | :--- | :--- |")
        foreach ($a in $tenantWideAssignments) {
            $principalName = if ($a.PrincipalUPN) { $a.PrincipalUPN } else { $a.PrincipalDisplayName }
            [void]$mdInfo.AppendLine("| $(Get-SafeMarkdown -Text $principalName) | $($a.PrincipalType) | $($a.UserType) | Tenant-wide (/) |")
        }
        [void]$mdInfo.AppendLine()
    }

    # Problematic Assignments (Groups, Service Principals, Guests)
    if ($problematicAssignments.Count -gt 0) {
        [void]$mdInfo.AppendLine("`n## ❌ Problematic Principal Assignments`n")
        [void]$mdInfo.AppendLine("The following assignments use groups, service principals, or guest users:`n")
        [void]$mdInfo.AppendLine("| Principal | Type | User Type | Scope |")
        [void]$mdInfo.AppendLine("| :--- | :--- | :--- | :--- |")
        foreach ($a in $problematicAssignments) {
            $principalName = if ($a.PrincipalUPN) { $a.PrincipalUPN } else { $a.PrincipalDisplayName }
            $scope = if ($a.DirectoryScopeId -eq '/') { 'Tenant-wide (/)' } else { 'Scoped' }
            [void]$mdInfo.AppendLine("| $(Get-SafeMarkdown -Text $principalName) | $($a.PrincipalType) | $($a.UserType) | $scope |")
        }
        [void]$mdInfo.AppendLine()
    }

    # Scoped Assignments
    if ($scopedAssignments.Count -gt 0) {
        [void]$mdInfo.AppendLine("`n## ✅ Scoped Assignments`n")
        [void]$mdInfo.AppendLine("The following Application Administrator assignments are scoped to specific applications:`n")
        [void]$mdInfo.AppendLine("| Principal | Type | Application | PA/QA App |")
        [void]$mdInfo.AppendLine("| :--- | :--- | :--- | :---: |")
        foreach ($a in $scopedAssignments | Sort-Object PrincipalDisplayName) {
            $principalName = if ($a.PrincipalUPN) { $a.PrincipalUPN } else { $a.PrincipalDisplayName }
            $appName = if ($a.AppDisplayName) { $a.AppDisplayName } else { 'Unknown app' }
            $paIcon = if ($a.IsPAApp) { '✅' } else { '❌' }
            [void]$mdInfo.AppendLine("| $(Get-SafeMarkdown -Text $principalName) | $($a.PrincipalType) | $(Get-SafeMarkdown -Text $appName) | $paIcon |")
        }
        [void]$mdInfo.AppendLine()
    }

    # Warnings
    if ($warnings.Count -gt 0) {
        [void]$mdInfo.AppendLine("`n## ⚠️ Warnings`n")
        foreach ($warning in $warnings) {
            [void]$mdInfo.AppendLine("- $warning")
        }
        [void]$mdInfo.AppendLine()
    }

    # Portal Link
    $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AllRolesBlade"
    $portalLinkText = Get-SafeMarkdown -Text "View in Entra Portal: Roles and administrators"
    [void]$mdInfo.AppendLine("`n[$portalLinkText]($portalLink)")

    # Replace placeholder with detailed information
    $testResultMarkdown = $mdInfo.ToString()
    #endregion Report Generation

    $params = @{
        TestId = '25384'
        Title  = 'Application admin rights are constrained to specific Private Access apps, not tenant-wide'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
