<#
.SYNOPSIS
    Checks the ratio of Global Administrator assignments to total privileged role assignments in the tenant.
#>

function Test-Assessment-21813{
    [ZtTest(
    	Category = 'Privileged access',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21813,
    	Title = 'High Global Administrator to privileged user ratio',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Administrator to privileged user ratio'
    Write-ZtProgress -Activity $activity -Status 'Getting privileged role assignments'

    $globalAdminRoleId = '62e90394-69f5-4237-9190-012177145e10'

    # Query all privileged role assignments from the database
    $sql = @"
SELECT principalId, principalDisplayName, userPrincipalName, roleDisplayName, roleDefinitionId, privilegeType, isPrivileged, "@odata.type"
FROM vwRole
WHERE isPrivileged = 1 AND "@odata.type" = '#microsoft.graph.user'
"@

    $roleAssignments = Invoke-DatabaseQuery -Database $Database -Sql $sql

    Write-PSFMessage "Found $($roleAssignments.Count) privileged role assignment records for users" -Level Verbose

    # Build user-role map (deduplicating users across active/eligible assignments)
    # Per requirements: Separate de-duplication for GA vs non-GA privileged roles
    # A user can be counted in BOTH buckets if they have GA + other privileged roles
    $allGAUsers = @{}           # Users with GA role (deduplicated by principalId)
    $allPrivilegedUsers = @{}   # Users with non-GA privileged roles (deduplicated by principalId)
    $userRoleMap = @{}          # Key: userId, Value: @{ user = userObject, roles = @(roleNames), isGA = $bool }

    foreach ($assignment in $roleAssignments) {
        $userId = $assignment.principalId
        $isGARole = $assignment.roleDefinitionId -eq $globalAdminRoleId

        # IMPORTANT: A user can be in BOTH buckets
        # Add to GA bucket if this is a GA role
        if ($isGARole) {
            $allGAUsers[$userId] = $assignment
        }

        # Add to non-GA privileged bucket if this is NOT a GA role
        if (-not $isGARole) {
            $allPrivilegedUsers[$userId] = $assignment
        }

        # Also maintain userRoleMap for display purposes
        if (-not $userRoleMap.ContainsKey($userId)) {
            $userRoleMap[$userId] = @{
                user = $assignment
                roles = [System.Collections.ArrayList]@()
                isGA = $false
            }
        }

        # Add role to user's role list (avoid duplicates)
        if ($assignment.roleDisplayName -notin $userRoleMap[$userId].roles) {
            [void]$userRoleMap[$userId].roles.Add($assignment.roleDisplayName)
        }

        # Mark if user is a Global Administrator
        if ($isGARole) {
            $userRoleMap[$userId].isGA = $true
            Write-PSFMessage "Marked user $($assignment.principalDisplayName) as Global Administrator" -Level Verbose
        }
    }

    # Separate counts for GA and non-GA privileged roles
    $gaRoleAssignmentCount = $allGAUsers.Count
    $privilegedRoleAssignmentCount = $allPrivilegedUsers.Count
    $totalPrivilegedRoleAssignmentCount = $gaRoleAssignmentCount + $privilegedRoleAssignmentCount

    # Calculate percentages
    if ($totalPrivilegedRoleAssignmentCount -gt 0) {
        $gaPercentage = [math]::Round(($gaRoleAssignmentCount / $totalPrivilegedRoleAssignmentCount) * 100, 2)
        $otherPercentage = [math]::Round(($privilegedRoleAssignmentCount / $totalPrivilegedRoleAssignmentCount) * 100, 2)
    } else {
        $gaPercentage = 0
        $otherPercentage = 0
    }

    # Determine status indicator
    if ($gaPercentage -lt 30) {
        $statusIndicator = '✅ Passed'
        $hasHealthyRatio = $true
    } elseif ($gaPercentage -ge 30 -and $gaPercentage -lt 50) {
        $statusIndicator = '⚠️ Investigate'
        $hasModerateRatio = $true
    } else {
        $statusIndicator = '❌ Failed'
        $hasHighRatio = $true
    }

    # Build simplified markdown output
    $mdInfo = "`n## Privileged role assignment summary`n`n"
    $mdInfo += "**Global administrator role count:** $gaRoleAssignmentCount ($gaPercentage%) - $statusIndicator`n`n"
    $mdInfo += "**Other privileged role count:** $privilegedRoleAssignmentCount ($otherPercentage%)`n`n"

    # Build user table - sorted with GAs first, then by display name within each group
    $mdInfo += "## User privileged role assignments`n`n"
    $mdInfo += "| User | Global administrator | Other Privileged Role(s) |`n"
    $mdInfo += "| :--- | :------------------- | :------ |`n"

    # Sort users: GAs first (by name), then non-GAs (by name)
    $sortedUsers = $userRoleMap.Values | Sort-Object @{Expression = {-not $_.isGA}}, @{Expression = {$_.user.principalDisplayName}}

    foreach ($userEntry in $sortedUsers) {
        $user = $userEntry.user
        $isGA = if ($userEntry.isGA) { 'Yes' } else { 'No' }

        # Get non-GA roles (exclude Global Administrator from the list)
        $otherRoles = $userEntry.roles | Where-Object { $_ -ne 'Global Administrator' } | Sort-Object
        $rolesList = if ($otherRoles.Count -gt 0) { ($otherRoles -join ', ') } else { '-' }

        # Create clickable user link
        $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/$($user.principalId)/hidePreviewBanner~/true"
        $safeDisplayName = Get-SafeMarkdown -Text $user.principalDisplayName
        $displayNameLink = "[$safeDisplayName]($userLink)"

        $mdInfo += "| $displayNameLink | $isGA | $rolesList |`n"
    }

    if ($userRoleMap.Count -eq 0) {
        $mdInfo += "| No privileged users found | - | - |`n"
    }

    #region Assessment Logic
    Write-PSFMessage "Assessment data: GACount=$gaRoleAssignmentCount, OtherPrivilegedCount=$privilegedRoleAssignmentCount, TotalCount=$totalPrivilegedRoleAssignmentCount, GARatio=$gaPercentage%" -Level Verbose

    if ($totalPrivilegedRoleAssignmentCount -eq 0) {
        $passed = $true
        $testResultMarkdown = "No privileged role assignments found in the tenant.$mdInfo"
    } elseif ($hasHealthyRatio) {
        $passed = $true
        $testResultMarkdown = "Less than 30% of privileged role assignments in the tenant are Global Administrator.$mdInfo"
    } elseif ($hasModerateRatio) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "Between 30-50% of privileged role assignments in the tenant are Global Administrator.$mdInfo"
    } else {
        $passed = $false
        $testResultMarkdown = "More than 50% of privileged role assignments in the tenant are Global Administrator.$mdInfo"
    }
    #endregion Assessment Logic

    $params = @{
        TestId = '21813'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Only add CustomStatus when it's "Investigate" (30-50% GA ratio)
    if ($hasModerateRatio) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
