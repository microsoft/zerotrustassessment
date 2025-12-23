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

    if (-not $assignments -or $assignments.Count -eq 0) {
        Add-ZtTestResultDetail -TestId '25384' -Status $true -Result "✅ No Application Administrator role assignments found.`n`n## Summary`n`nNo assignments detected in the tenant."
        return
    }

    # Pre-fetch scoped resources to minimize API calls
    Write-ZtProgress -Activity $activity -Status 'Resolving scoped applications'

    # Query 4: Bulk fetch all Private Access and Quick Access apps by tags
    $paQuickAccessApps = @()
    try {
        $paQuickAccessApps = Invoke-ZtGraphRequest -RelativeUri "applications" -Filter "(tags/any(t: t eq 'PrivateAccessNonWebApplication') or tags/any(t: t eq 'NetworkAccessQuickAccessApplication'))" -Select 'id,displayName,appId,tags' -ApiVersion v1.0
    } catch {
        Write-PSFMessage "Unable to query Private Access/Quick Access apps by tags" -Level Verbose
    }

    # Build PA/QA app lookup by appId and id for O(1) lookups
    $paQaAppLookup = @{}
    foreach ($app in $paQuickAccessApps) {
        if ($app.appId) { $paQaAppLookup[$app.appId] = $app }
        if ($app.id) { $paQaAppLookup[$app.id] = $app }
    }

    # Collect scoped IDs in single pass
    $spIds = [System.Collections.Generic.List[string]]::new()
    $appIds = [System.Collections.Generic.List[string]]::new()

    foreach ($assignment in $assignments) {
        if ($assignment.directoryScopeId -ne '/') {
            $scopeId = $assignment.directoryScopeId -replace '^/', ''
            if ($scopeId -match '^servicePrincipals/(.+)') {
                $spIds.Add($Matches[1])
            }
            elseif ($scopeId -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
                $appIds.Add($scopeId)
            }
        }
    }

    # Build lookup hashtables
    $spLookup = @{}
    $appLookup = @{}

    # Query 3: Batch fetch service principals using $filter with 'in' operator
    $uniqueSpIds = $spIds | Select-Object -Unique
    if ($uniqueSpIds.Count -gt 0) {
        # Batch in groups of 15 to avoid URL length limits
        for ($i = 0; $i -lt $uniqueSpIds.Count; $i += 15) {
            $batch = $uniqueSpIds[$i..([Math]::Min($i + 14, $uniqueSpIds.Count - 1))]
            $idList = ($batch | ForEach-Object { "'$_'" }) -join ','
            try {
                $sps = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals" -Filter "id in ($idList)" -Select 'id,displayName,appId' -ApiVersion v1.0
                foreach ($sp in $sps) {
                    $spLookup[$sp.id] = $sp
                }
            } catch {
                Write-PSFMessage "Batch SP fetch failed, falling back to individual calls" -Level Verbose
                foreach ($spId in $batch) {
                    try {
                        $sp = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$spId" -Select 'id,displayName,appId' -ApiVersion v1.0
                        if ($sp) { $spLookup[$spId] = $sp }
                    } catch {
                        Write-PSFMessage "Unable to resolve service principal $spId" -Level Verbose
                    }
                }
            }
        }
    }

    # Collect all app IDs to fetch (from scoped apps + service principal appIds)
    $allAppIds = @($appIds) + @($spLookup.Values | Where-Object { $_.appId } | ForEach-Object { $_.appId }) | Select-Object -Unique
    # Filter out IDs already in PA/QA lookup
    $appIdsToFetch = $allAppIds | Where-Object { -not $paQaAppLookup.ContainsKey($_) }

    if ($appIdsToFetch.Count -gt 0) {
        # Batch fetch applications
        for ($i = 0; $i -lt $appIdsToFetch.Count; $i += 15) {
            $batch = $appIdsToFetch[$i..([Math]::Min($i + 14, $appIdsToFetch.Count - 1))]
            $idList = ($batch | ForEach-Object { "'$_'" }) -join ','
            try {
                $apps = Invoke-ZtGraphRequest -RelativeUri "applications" -Filter "id in ($idList) or appId in ($idList)" -Select 'id,displayName,appId,tags' -ApiVersion v1.0
                foreach ($app in $apps) {
                    if ($app.id) { $appLookup[$app.id] = $app }
                    if ($app.appId) { $appLookup[$app.appId] = $app }
                }
            } catch {
                Write-PSFMessage "Batch app fetch failed, falling back to individual calls" -Level Verbose
                foreach ($appId in $batch) {
                    try {
                        if ($appId -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
                            $app = Invoke-ZtGraphRequest -RelativeUri "applications/$appId" -Select 'id,displayName,appId,tags' -ApiVersion v1.0
                        } else {
                            $app = Invoke-ZtGraphRequest -RelativeUri "applications" -Filter "appId eq '$appId'" -Select 'id,displayName,appId,tags' -ApiVersion v1.0
                        }
                        if ($app) { $appLookup[$appId] = $app }
                    } catch {
                        Write-PSFMessage "Unable to resolve application $appId" -Level Verbose
                    }
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $true
    $tenantWideAssignments = [System.Collections.Generic.List[PSCustomObject]]::new()
    $scopedAssignments = [System.Collections.Generic.List[PSCustomObject]]::new()
    $problematicAssignments = [System.Collections.Generic.List[PSCustomObject]]::new()
    $warnings = [System.Collections.Generic.List[string]]::new()

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

        # Check if tenant-wide
        if ($assignment.directoryScopeId -eq '/') {
            $tenantWideAssignments.Add($assignmentInfo)
            $passed = $false
        }
        else {
            # Scoped assignment - resolve from hashtables
            $scopeId = $assignment.directoryScopeId -replace '^/', ''

            if ($scopeId -match '^servicePrincipals/(.+)') {
                $spId = $Matches[1]
                if ($spLookup.ContainsKey($spId)) {
                    $sp = $spLookup[$spId]
                    $assignmentInfo.AppDisplayName = $sp.displayName
                    $assignmentInfo.AppId = $sp.appId

                    # Check PA/QA lookup first, then fallback to appLookup
                    $app = if ($paQaAppLookup.ContainsKey($sp.appId)) { $paQaAppLookup[$sp.appId] }
                           elseif ($appLookup.ContainsKey($sp.appId)) { $appLookup[$sp.appId] }
                           else { $null }
                    if ($app) {
                        $assignmentInfo.IsPAApp = ($app.tags -contains 'PrivateAccessNonWebApplication') -or ($app.tags -contains 'NetworkAccessQuickAccessApplication')
                    }
                }
            }
            else {
                # Check PA/QA lookup first, then appLookup
                $app = if ($paQaAppLookup.ContainsKey($scopeId)) { $paQaAppLookup[$scopeId] }
                       elseif ($appLookup.ContainsKey($scopeId)) { $appLookup[$scopeId] }
                       else { $null }
                if ($app) {
                    $assignmentInfo.AppDisplayName = $app.displayName
                    $assignmentInfo.AppId = $app.appId
                    $assignmentInfo.IsPAApp = ($app.tags -contains 'PrivateAccessNonWebApplication') -or ($app.tags -contains 'NetworkAccessQuickAccessApplication')
                }
            }

            $scopedAssignments.Add($assignmentInfo)
        }

        # Check for problematic principals
        if ($principalType -in @('group', 'servicePrincipal') -or $assignment.principal.userType -eq 'Guest') {
            $problematicAssignments.Add($assignmentInfo)
            $passed = $false
        }
    }

    # Check warnings
    if ($assignments.Count -gt 5) {
        $warnings.Add("Assignment count ($($assignments.Count)) exceeds recommended threshold of 5")
    }

    $scopedNonPACount = ($scopedAssignments | Where-Object { -not $_.IsPAApp -and $_.AppDisplayName }).Count
    if ($scopedNonPACount -gt 0) {
        $warnings.Add("$scopedNonPACount scoped assignment(s) to apps that are not confirmed as Private Access or Quick Access apps")
    }

    # Generate result message
    if ($passed -and $warnings.Count -eq 0) {
        $testResultMarkdown = "✅ Application Administrator role is scoped to specific applications; no tenant-wide assignments, groups, guests, or service principals detected.`n`n%TestResult%"
    }
    elseif ($passed -and $warnings.Count -gt 0) {
        $testResultMarkdown = "⚠️ Application Administrator role has scoped assignments, but some warnings were detected.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Application Administrator role has tenant-wide assignments or is assigned to groups, guests, or service principals.`n`n%TestResult%"
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
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo.ToString()
    #endregion Report Generation

    $params = @{
        TestId = '25384'
        Title  = 'Application admin rights are constrained to specific Private Access apps, not tenant-wide'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
