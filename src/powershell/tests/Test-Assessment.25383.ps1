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
    Required API: roleManagement/directory/roleDefinitions, roleManagement/directory/roleAssignments (v1.0)
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
    $allRoleDefinitions = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleDefinitions' -ApiVersion v1.0
    $gaRole = $allRoleDefinitions | Where-Object { $_.displayName -eq 'Global Administrator' }
    $gsaRole = $allRoleDefinitions | Where-Object { $_.displayName -eq 'Global Secure Access Administrator' }

    # Get tenant ID for portal links
    $organization = Invoke-ZtGraphRequest -RelativeUri 'organization' -ApiVersion v1.0
    $tenantId = $organization[0].id

    # Query Q2/Q3: Get all role assignments with expanded principal
    Write-ZtProgress -Activity $activity -Status 'Getting role assignments'
    $allRoleAssignments = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleAssignments' `
        -QueryParameters @{'$expand' = 'principal($select=id,displayName,userPrincipalName,mail,userType,accountEnabled)' } `
        -ApiVersion v1.0

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
            RoleName         = $roleName
            RoleDefinitionId = $null
            TemplateId       = $null
            Found            = $false
            TotalCount       = 0
            Issues           = @()
            ValidAssignments = @()
            HasIssues        = $false
            ExceedsThreshold = $false
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
                '*user' { 'User' }
                '*group' { 'Group' }
                '*servicePrincipal' { 'ServicePrincipal' }
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
            if ($principalType -eq 'Group') {
                $assignmentInfo.Issue = 'Group assignment'
                $result.Issues += $assignmentInfo
            }
            elseif ($principalType -eq 'ServicePrincipal') {
                $assignmentInfo.Issue = 'Service Principal assignment'
                $result.Issues += $assignmentInfo
            }
            elseif ($principalType -eq 'User' -and $principal.userType -eq 'Guest') {
                $assignmentInfo.Issue = 'Guest user assignment'
                $result.Issues += $assignmentInfo
            }
            elseif ($principalType -eq 'User' -and $principal.accountEnabled -eq $true) {
                # Only enabled Member users are considered valid
                $result.ValidAssignments += $assignmentInfo
            }
        }

        # TotalCount = Issues + ValidAssignments (disabled users excluded)
        $result.TotalCount = $result.Issues.Count + $result.ValidAssignments.Count
        $result.HasIssues = $result.Issues.Count -gt 0
        $result.ExceedsThreshold = $result.TotalCount -gt 5

        $allResults += $result
    }
    #endregion Data Collection

    #region Assessment Logic
    # Determine result status based on spec evaluation logic
    $rolesNotFound = ($allResults | Where-Object { -not $_.Found }).Count -gt 0
    $hasAnyIssues = ($allResults | Where-Object { $_.HasIssues }).Count -gt 0
    $exceedsAnyThreshold = ($allResults | Where-Object { $_.ExceedsThreshold }).Count -gt 0

    $passed = $false
    $customStatus = $null

    # Investigate: Unable to retrieve role assignments or role definitions
    if ($rolesNotFound) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to retrieve role assignments or role definitions. Manual verification required.`n`n%TestResult%"
    }
    # Fail: Groups, guests, or service principals assigned
    elseif ($hasAnyIssues) {
        $testResultMarkdown = "❌ GA/GSA roles include groups, guests, service principals, or an excessive number of assignments requiring immediate review.`n`n%TestResult%"
    }
    # Warn (Investigate): Excessive assignments but no other issues
    elseif ($exceedsAnyThreshold) {
        $passed = $true
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ GA/GSA roles exceed the recommended assignment threshold (>5). Review and reduce if possible.`n`n%TestResult%"
    }
    # Pass: All principals are individual Member users within limits
    else {
        $passed = $true
        $testResultMarkdown = "✅ GA/GSA roles are limited to vetted Member users; no groups, guests, or service principals are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build report
    $mdInfo = ''

    foreach ($result in $allResults) {
        $mdInfo += "`n## $($result.RoleName) Assignments`n`n"

        if (-not $result.Found) {
            $mdInfo += "ℹ️ $($result.RoleName) role definition not found. Verify tenant license/feature availability.`n`n"
            continue
        }

        $mdInfo += "**Role Definition ID**: $($result.RoleDefinitionId)  `n"
        $mdInfo += "**Total assignments**: $($result.TotalCount)  `n"
        $mdInfo += "**Threshold**: 5  `n"

        if ($result.HasIssues) {
            $mdInfo += "**Status**: ❌ Issues found`n`n"
        }
        elseif ($result.ExceedsThreshold) {
            $mdInfo += "**Status**: ⚠️ Exceeds threshold`n`n"
        }
        else {
            $mdInfo += "**Status**: ✅ Compliant`n`n"
        }

        if ($result.Issues.Count -gt 0) {
            $mdInfo += "### ❌ Non-compliant assignments`n`n"
            $mdInfo += "| Name | Principal name | Type | User type |`n"
            $mdInfo += "| :----------- | :-- | :--- | :-------- |`n"

            $maxDisplay = 5
            $displayIssues = $result.Issues
            if ($result.Issues.Count -gt $maxDisplay) {
                $displayIssues = $result.Issues[0..($maxDisplay - 1)]
            }

            foreach ($issue in $displayIssues) {
                $mdInfo += "| $(Get-SafeMarkdown $issue.DisplayName) | $(Get-SafeMarkdown $issue.UPN) | $($issue.Type) | $($issue.UserType) |`n"
            }

            if ($result.Issues.Count -gt $maxDisplay) {
                $roleNameEncoded = [System.Uri]::EscapeDataString($result.RoleName)
                $portalUrl = "https://entra.microsoft.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/$($result.TemplateId)/roleId/$($result.TemplateId)/roleTemplateId/$($result.TemplateId)/roleName/$roleNameEncoded/isRoleCustom~/false/resourceScopeId/%2F/resourceId/$tenantId"
                $mdInfo += "`n*Showing first $maxDisplay of $($result.Issues.Count) records. [View all assignments in Entra Portal]($portalUrl)*`n"
            }
            $mdInfo += "`n"
        }

        if ($result.ValidAssignments.Count -gt 0) {
            $mdInfo += "### ✅ Valid Member user assignments`n`n"
            $mdInfo += "| Name | Principal name | User type | Account enabled |`n"
            $mdInfo += "| :----------- | :-- | :-------- | :-------------- |`n"

            $maxDisplay = 5
            $displayValid = $result.ValidAssignments
            if ($result.ValidAssignments.Count -gt $maxDisplay) {
                $displayValid = $result.ValidAssignments[0..($maxDisplay - 1)]
            }

            foreach ($valid in $displayValid) {
                $mdInfo += "| $(Get-SafeMarkdown $valid.DisplayName) | $(Get-SafeMarkdown $valid.UPN) | $($valid.UserType) | $($valid.AccountEnabled) |`n"
            }

            if ($result.ValidAssignments.Count -gt $maxDisplay) {
                $roleNameEncoded = [System.Uri]::EscapeDataString($result.RoleName)
                $portalUrl = "https://entra.microsoft.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/$($result.TemplateId)/roleId/$($result.TemplateId)/roleTemplateId/$($result.TemplateId)/roleName/$roleNameEncoded/isRoleCustom~/false/resourceScopeId/%2F/resourceId/$tenantId"
                $mdInfo += "`n*Showing first $maxDisplay of $($result.ValidAssignments.Count) records. [View all assignments in Entra Portal]($portalUrl)*`n"
            }
            $mdInfo += "`n"
        }
    }

    $mdInfo += "`n## Portal Link`n`n"
    $mdInfo += "[Roles and administrators](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles)`n"

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
