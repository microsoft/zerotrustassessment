<#
.SYNOPSIS
    Validates that Global Administrator and Global Secure Access Administrator roles are tightly limited.

.DESCRIPTION
    This test checks if Global Administrator (GA) and Global Secure Access Administrator (GSA)
    roles are assigned only to vetted Member users, without groups, guests, or service principals,
    to prevent tenant-wide compromise from a single identity compromise.

.NOTES
    Test ID: 25383
    Category: Global Secure Access
    Required API: roleManagement/directory/roleDefinitions, roleManagement/directory/roleAssignments (beta)
#>

function Test-Assessment-25383 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('AAD_PREMIUM'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 25383,
        Title = 'Global and GSA admin privileges are tightly limited to prevent tenant-wide compromise',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Administrator and GSA role assignments'
    Write-ZtProgress -Activity $activity -Status 'Getting role definitions'

    # Query Q1: Get all role definitions, then filter locally for GA and GSA
    $allRoleDefinitions = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleDefinitions' -ApiVersion beta
    $gaRole = $allRoleDefinitions | Where-Object { $_.displayName -eq 'Global Administrator' }
    $gsaRole = $allRoleDefinitions | Where-Object { $_.displayName -eq 'Global Secure Access Administrator' }

    # Get tenant ID for portal links
    $organization = Invoke-ZtGraphRequest -RelativeUri 'organization' -ApiVersion v1.0
    $tenantId = $organization[0].id

    # Query Q2/Q3: Get all role assignments with expanded principal
    Write-ZtProgress -Activity $activity -Status 'Getting role assignments'
    $allRoleAssignments = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleAssignments' `
        -QueryParameters @{'$expand' = 'principal($select=id,displayName,userPrincipalName,mail,userType,accountEnabled)' } `
        -ApiVersion beta

    # Define roles to check
    $rolesToCheck = @(
        @{ Role = $gaRole; Name = 'Global Administrator' }
        @{ Role = $gsaRole; Name = 'Global Secure Access Administrator' }
    )

    $allResults = @()

    foreach ($roleInfo in $rolesToCheck) {
        $role = $roleInfo.Role
        $roleName = $roleInfo.Name

        $result = [PSCustomObject]@{
            RoleName            = $roleName
            RoleDefinitionId    = $null
            TemplateId          = $null
            Found               = $false
            TotalCount          = 0
            Issues              = @()
            DisabledAssignments = @()
            ValidAssignments    = @()
            HasIssues           = $false
            HasDisabledUsers    = $false
            ExceedsThreshold    = $false
        }

        if (-not $role -or $role.Count -eq 0) {
            $allResults += $result
            continue
        }

        $result.Found = $true
        $result.RoleDefinitionId = $role.id
        $result.TemplateId = $role.templateId

        # Filter assignments locally for this role
        $assignments = $allRoleAssignments | Where-Object { $_.roleDefinitionId -eq $role.id }

        foreach ($assignment in $assignments) {
            $principal = $assignment.principal

            # Determine principal type from @odata.type
            $principalType = switch -Wildcard ($principal.'@odata.type') {
                '*user' { 'user' }
                '*group' { 'group' }
                '*servicePrincipal' { 'servicePrincipal' }
                default { 'Unknown' }
            }

            $assignmentInfo = [PSCustomObject]@{
                DisplayName    = $principal.displayName
                UPN            = $principal.userPrincipalName
                Type           = $principalType
                UserType       = if ($principal.userType) { $principal.userType } else { 'N/A' }
                AccountEnabled = $principal.accountEnabled
                Issue          = $null
            }

            # Check for non-compliant assignments
            if ($principalType -eq 'group') {
                $assignmentInfo.Issue = 'Group assignment'
                $result.Issues += $assignmentInfo
            }
            elseif ($principalType -eq 'servicePrincipal') {
                $assignmentInfo.Issue = 'Service Principal assignment'
                $result.Issues += $assignmentInfo
            }
            elseif ($principalType -eq 'user' -and $principal.userType -eq 'Guest') {
                $assignmentInfo.Issue = 'Guest user assignment'
                $result.Issues += $assignmentInfo
            }
            elseif ($principalType -eq 'user' -and $principal.accountEnabled -eq $false) {
                # Disabled Member users - latent risk, indicates poor lifecycle management
                $assignmentInfo.Issue = 'Disabled account with privileged role'
                $result.DisabledAssignments += $assignmentInfo
            }
            elseif ($principalType -eq 'user' -and $principal.accountEnabled -eq $true) {
                # Only enabled Member users are considered valid
                $result.ValidAssignments += $assignmentInfo
            }
        }

        # TotalCount includes all categorized assignments
        $result.TotalCount = $result.Issues.Count + $result.DisabledAssignments.Count + $result.ValidAssignments.Count
        $result.HasIssues = $result.Issues.Count -gt 0
        $result.HasDisabledUsers = $result.DisabledAssignments.Count -gt 0
        $result.ExceedsThreshold = $result.TotalCount -gt 5

        $allResults += $result
    }
    #endregion Data Collection

    #region Assessment Logic
    # Determine result status based on spec evaluation logic
    $gaResult = $allResults | Where-Object { $_.RoleName -eq 'Global Administrator' }

    # Per spec: GA not found → Fail (critical role must exist)
    # Per spec: GSA not found → Skip GSA evaluation (role may not be provisioned)
    $gaNotFound = -not $gaResult.Found

    # Only evaluate roles that were found
    $foundResults = $allResults | Where-Object { $_.Found }
    $hasAnyIssues = ($foundResults | Where-Object { $_.HasIssues }).Count -gt 0
    $hasAnyDisabledUsers = ($foundResults | Where-Object { $_.HasDisabledUsers }).Count -gt 0
    $exceedsAnyThreshold = ($foundResults | Where-Object { $_.ExceedsThreshold }).Count -gt 0

    $passed = $false
    $customStatus = $null

    # Fail: Global Administrator role not found (critical role must exist)
    if ($gaNotFound) {
        $testResultMarkdown = "❌ Global Administrator role definition not found. This is a critical role that must exist in all tenants.`n`n%TestResult%"
    }
    # Fail: Groups, guests, or service principals assigned
    elseif ($hasAnyIssues) {
        $testResultMarkdown = "❌ GA/GSA roles include groups, guests, or service principals requiring immediate review.`n`n%TestResult%"
    }
    # Investigate: Disabled users with privileged roles - latent risk
    elseif ($hasAnyDisabledUsers) {
        $passed = $true
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ GA/GSA roles include disabled Member users or exceed recommended assignment thresholds; review and remediate.`n`n%TestResult%"
    }
    # Investigate: Excessive assignments but no other issues
    elseif ($exceedsAnyThreshold) {
        $passed = $true
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ GA/GSA roles include disabled Member users or exceed recommended assignment thresholds; review and remediate.`n`n%TestResult%"
    }
    # Pass: All principals are enabled Member users within limits
    else {
        $passed = $true
        $testResultMarkdown = "✅ GA/GSA roles are limited to enabled, vetted Member users; no groups, guests, service principals, or disabled accounts are assigned, and assignment counts are within approved limits.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build report
    $mdInfo = ''

    foreach ($result in $allResults) {
        $mdInfo += "`n## [$($result.RoleName) Assignments](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles)`n`n"

        if (-not $result.Found) {
            if ($result.RoleName -eq 'Global Administrator') {
                $mdInfo += "❌ $($result.RoleName) role definition not found. This is a critical role that must exist.`n`n"
            }
            else {
                $mdInfo += "ℹ️ $($result.RoleName) role definition not found. Skipping evaluation (role may not be provisioned in tenant).`n`n"
            }
            continue
        }

        $mdInfo += "**Role Definition ID**: $($result.RoleDefinitionId)  `n"
        $mdInfo += "**Total Assignment Count**: $($result.TotalCount)  `n"
        $mdInfo += "**Valid Assignment Count**: $($result.ValidAssignments.Count)  `n"
        $mdInfo += "**Issue Count**: $($result.Issues.Count + $result.DisabledAssignments.Count)  `n`n"

        if ($result.Issues.Count -gt 0) {
            $mdInfo += "### ❌ Non-compliant assignments`n`n"
            $mdInfo += "| Name | Principal name | Type | User type | Account enabled | Status |`n"
            $mdInfo += "| :----------- | :-- | :--- | :-------- | :-------------- | :----- |`n"

            $maxDisplay = 5
            $displayIssues = $result.Issues
            if ($result.Issues.Count -gt $maxDisplay) {
                $displayIssues = $result.Issues[0..($maxDisplay - 1)]
            }

            foreach ($issue in $displayIssues) {
                $mdInfo += "| $(Get-SafeMarkdown $issue.DisplayName) | $(Get-SafeMarkdown $issue.UPN) | $($issue.Type) | $($issue.UserType) | $($issue.AccountEnabled) | Fail |`n"
            }

            if ($result.Issues.Count -gt $maxDisplay) {
                $roleNameEncoded = [System.Uri]::EscapeDataString($result.RoleName)
                $portalUrl = "https://entra.microsoft.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/$($result.TemplateId)/roleId/$($result.TemplateId)/roleTemplateId/$($result.TemplateId)/roleName/$roleNameEncoded/isRoleCustom~/false/resourceScopeId/%2F/resourceId/$tenantId"
                $mdInfo += "`n*Showing first $maxDisplay of $($result.Issues.Count) records. [View all assignments in Entra Portal]($portalUrl)*`n"
            }
            $mdInfo += "`n"
        }

        if ($result.DisabledAssignments.Count -gt 0) {
            $mdInfo += "### ⚠️ Disabled accounts with privileged roles`n`n"
            $mdInfo += "| Name | Principal name | Type | User type | Account enabled | Status |`n"
            $mdInfo += "| :----------- | :-- | :--- | :-------- | :-------------- | :----- |`n"

            $maxDisplay = 5
            $displayDisabled = $result.DisabledAssignments
            if ($result.DisabledAssignments.Count -gt $maxDisplay) {
                $displayDisabled = $result.DisabledAssignments[0..($maxDisplay - 1)]
            }

            foreach ($disabled in $displayDisabled) {
                $mdInfo += "| $(Get-SafeMarkdown $disabled.DisplayName) | $(Get-SafeMarkdown $disabled.UPN) | $($disabled.Type) | $($disabled.UserType) | $($disabled.AccountEnabled) | Investigate |`n"
            }

            if ($result.DisabledAssignments.Count -gt $maxDisplay) {
                $roleNameEncoded = [System.Uri]::EscapeDataString($result.RoleName)
                $portalUrl = "https://entra.microsoft.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/$($result.TemplateId)/roleId/$($result.TemplateId)/roleTemplateId/$($result.TemplateId)/roleName/$roleNameEncoded/isRoleCustom~/false/resourceScopeId/%2F/resourceId/$tenantId"
                $mdInfo += "`n*Showing first $maxDisplay of $($result.DisabledAssignments.Count) records. [View all assignments in Entra Portal]($portalUrl)*`n"
            }
            $mdInfo += "`n"
        }

        if ($result.ValidAssignments.Count -gt 0) {
            $mdInfo += "### ✅ Valid Member user assignments`n`n"
            $mdInfo += "| Name | Principal name | Type | User type | Account enabled | Status |`n"
            $mdInfo += "| :----------- | :-- | :--- | :-------- | :-------------- | :----- |`n"

            $maxDisplay = 5
            $displayValid = $result.ValidAssignments
            if ($result.ValidAssignments.Count -gt $maxDisplay) {
                $displayValid = $result.ValidAssignments[0..($maxDisplay - 1)]
            }

            foreach ($valid in $displayValid) {
                $mdInfo += "| $(Get-SafeMarkdown $valid.DisplayName) | $(Get-SafeMarkdown $valid.UPN) | $($valid.Type) | $($valid.UserType) | $($valid.AccountEnabled) | Valid |`n"
            }

            if ($result.ValidAssignments.Count -gt $maxDisplay) {
                $roleNameEncoded = [System.Uri]::EscapeDataString($result.RoleName)
                $portalUrl = "https://entra.microsoft.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/$($result.TemplateId)/roleId/$($result.TemplateId)/roleTemplateId/$($result.TemplateId)/roleName/$roleNameEncoded/isRoleCustom~/false/resourceScopeId/%2F/resourceId/$tenantId"
                $mdInfo += "`n*Showing first $maxDisplay of $($result.ValidAssignments.Count) records. [View all assignments in Entra Portal]($portalUrl)*`n"
            }
            $mdInfo += "`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25383'
        Title  = 'Global and GSA admin privileges are tightly limited to prevent tenant-wide compromise'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
