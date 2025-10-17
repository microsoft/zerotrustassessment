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
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Administrator to privileged user ratio'
    Write-ZtProgress -Activity $activity -Status 'Getting privileged roles'

    $globalAdminRoleId = '62e90394-69f5-4237-9190-012177145e10'

    # Collections to store unique users - separated by active/eligible
    $activeGAUsers = @{}
    $activePrivilegedUsers = @{}
    $eligibleGAUsers = @{}
    $eligiblePrivilegedUsers = @{}

    # Deduplicated collections (combined active + eligible)
    $allGAUsers = @{}
    $allPrivilegedUsers = @{}

    # Helper function to expand group members
    function Get-GroupMembers {
        param([string]$GroupId)
        try {
            $members = Invoke-ZtGraphRequest -RelativeUri "groups/$GroupId/members" -ApiVersion beta -Select 'userPrincipalName,displayName,id'
            return $members
        } catch {
            Write-PSFMessage "Failed to get members for group $GroupId : $_" -Level Warning
            return @()
        }
    }

    # Step 1: Get all privileged role definitions
    # Query 1 - Q1: Find all privileged directory role definitions in the tenant
    Write-ZtProgress -Activity $activity -Status 'Getting privileged role definitions'
    $privilegedRoleDefinitions = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleDefinitions' -Filter 'isPrivileged eq true' -ApiVersion beta
    Write-PSFMessage "Found $($privilegedRoleDefinitions.Count) privileged role definitions" -Level Verbose

    # Step 2: Get ACTIVE role assignments
    Write-ZtProgress -Activity $activity -Status 'Getting active role assignments'
    foreach ($roleDefinition in $privilegedRoleDefinitions) {
        # Query 1 - Q2: Find directory role instance using roleTemplateId from Q1
        $directoryRoles = Invoke-ZtGraphRequest -RelativeUri 'directoryRoles' -Filter "roleTemplateId eq '$($roleDefinition.templateId)'" -ApiVersion beta

        foreach ($directoryRole in $directoryRoles) {
            # Query 1 - Q3/Q5: Get members of the directory role (users and groups)
            $members = Invoke-ZtGraphRequest -RelativeUri "directoryRoles/$($directoryRole.id)/members" -ApiVersion beta -Select 'userPrincipalName,displayName,id'

            foreach ($member in $members) {
                # Expand groups to get individual users
                if ($member.'@odata.type' -eq '#microsoft.graph.group') {
                    # Query 1 - Q4/Q6: Get group members
                    $groupMembers = Get-GroupMembers -GroupId $member.id
                    foreach ($groupMember in $groupMembers) {
                        if ($groupMember.'@odata.type' -eq '#microsoft.graph.user') {
                            if ($roleDefinition.templateId -eq $globalAdminRoleId) {
                                # Q3/Q4: Active GA role assignments (ActiveGARoleAssignments)
                                $activeGAUsers[$groupMember.id] = $groupMember
                            } else {
                                # Q5/Q6: Active non-GA privileged role assignments (ActivePrivilegedRoleAssignments)
                                $activePrivilegedUsers[$groupMember.id] = $groupMember
                            }
                        }
                    }
                } elseif ($member.'@odata.type' -eq '#microsoft.graph.user') {
                    if ($roleDefinition.templateId -eq $globalAdminRoleId) {
                        # Q3: Active GA role assignments (ActiveGARoleAssignments)
                        $activeGAUsers[$member.id] = $member
                    } else {
                        # Q5: Active non-GA privileged role assignments (ActivePrivilegedRoleAssignments)
                        $activePrivilegedUsers[$member.id] = $member
                    }
                }
            }
        }
    }

    # Step 3: Get ELIGIBLE role assignments for GA
    # Query 2 - Q1: Get eligible GA role assignments using roleDefinitionId
    Write-ZtProgress -Activity $activity -Status 'Getting eligible GA assignments'
    $eligibleGAAssignmentResults = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleEligibilitySchedules' -Filter "roleDefinitionId eq '$globalAdminRoleId'" -QueryParameters @{'$expand' = 'principal'} -ApiVersion beta

    foreach ($assignment in $eligibleGAAssignmentResults) {
        $principal = $assignment.principal
        if ($principal.'@odata.type' -eq '#microsoft.graph.group') {
            # Query 2 - Q2: Get group members for eligible GA assignments
            $groupMembers = Get-GroupMembers -GroupId $principal.id
            foreach ($groupMember in $groupMembers) {
                if ($groupMember.'@odata.type' -eq '#microsoft.graph.user') {
                    # Q1/Q2: Eligible GA role assignments (EligibleGARoleAssignments)
                    $eligibleGAUsers[$groupMember.id] = $groupMember
                }
            }
        } elseif ($principal.'@odata.type' -eq '#microsoft.graph.user') {
            # Q1: Eligible GA role assignments (EligibleGARoleAssignments)
            $eligibleGAUsers[$principal.id] = $principal
        }
    }

    # Step 4: Get ELIGIBLE role assignments for other privileged roles
    # Query 2 - Q3: Find all privileged directory role definitions (reusing from Step 1)
    # Query 2 - Q4: Get eligible non-GA privileged role assignments
    Write-ZtProgress -Activity $activity -Status 'Getting eligible privileged role assignments'
    foreach ($roleDefinition in $privilegedRoleDefinitions) {
        if ($roleDefinition.templateId -ne $globalAdminRoleId) {
            # Query 2 - Q4: Get eligible assignments for each non-GA privileged role
            $eligibleAssignments = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleEligibilitySchedules' -Filter "roleDefinitionId eq '$($roleDefinition.id)'" -QueryParameters @{'$expand' = 'principal'} -ApiVersion beta

            foreach ($assignment in $eligibleAssignments) {
                $principal = $assignment.principal
                if ($principal.'@odata.type' -eq '#microsoft.graph.group') {
                    # Query 2 - Q5: Get group members for eligible privileged assignments
                    $groupMembers = Get-GroupMembers -GroupId $principal.id
                    foreach ($groupMember in $groupMembers) {
                        if ($groupMember.'@odata.type' -eq '#microsoft.graph.user') {
                            # Q4/Q5: Eligible non-GA privileged role assignments (EligiblePrivilegedRoleAssignments)
                            $eligiblePrivilegedUsers[$groupMember.id] = $groupMember
                        }
                    }
                } elseif ($principal.'@odata.type' -eq '#microsoft.graph.user') {
                    # Q4: Eligible non-GA privileged role assignments (EligiblePrivilegedRoleAssignments)
                    $eligiblePrivilegedUsers[$principal.id] = $principal
                }
            }
        }
    }

    # Step 5: De-duplicate - Combine active and eligible assignments
    Write-ZtProgress -Activity $activity -Status 'Deduplicating role assignments'

    # Combine and deduplicate GA users using the + operator (more efficient than looping)
    $allGAUsers = $activeGAUsers.Clone()
    foreach ($userId in $eligibleGAUsers.Keys) {
        if (-not $allGAUsers.ContainsKey($userId)) {
            $allGAUsers[$userId] = $eligibleGAUsers[$userId]
        }
    }

    # Combine and deduplicate all privileged users
    $allPrivilegedUsers = $activePrivilegedUsers.Clone()
    foreach ($userId in $eligiblePrivilegedUsers.Keys) {
        if (-not $allPrivilegedUsers.ContainsKey($userId)) {
            $allPrivilegedUsers[$userId] = $eligiblePrivilegedUsers[$userId]
        }
    }

    # Calculate counts and ratio per requirements:
    # - GARoleAssignmentCount (deduplicated GA users)
    # - PrivilegedRoleAssignmentCount (deduplicated non-GA privileged users)
    # - TotalPrivilegedRoleAssignmentCount = GARoleAssignmentCount + PrivilegedRoleAssignmentCount

    $activeGACount = $activeGAUsers.Count
    $eligibleGACount = $eligibleGAUsers.Count
    $gaRoleAssignmentCount = $allGAUsers.Count  # Deduplicated GA count

    $activePrivilegedCount = $activePrivilegedUsers.Count
    $eligiblePrivilegedCount = $eligiblePrivilegedUsers.Count
    $privilegedRoleAssignmentCount = $allPrivilegedUsers.Count  # Deduplicated non-GA privileged count (already excludes GA)
    $totalPrivilegedRoleAssignmentCount = $gaRoleAssignmentCount + $privilegedRoleAssignmentCount  # GA + non-GA

    if ($totalPrivilegedRoleAssignmentCount -gt 0) {
        $gaRatioPercentage = [math]::Round(($gaRoleAssignmentCount / $totalPrivilegedRoleAssignmentCount) * 100, 2)
    } else {
        $gaRatioPercentage = 0
    }

    # Build details section for markdown
    $mdInfo = ''

    # Always show summary information
    $mdInfo += "`n## Assessment summary`n`n"
    $mdInfo += "| Metric | Count |`n"
    $mdInfo += "| :----- | :---- |`n"
    $mdInfo += "| Active GA assignments | $activeGACount |`n"
    $mdInfo += "| Eligible GA assignments | $eligibleGACount |`n"
    $mdInfo += "| Global Administrator assignments (deduplicated)| $gaRoleAssignmentCount |`n"
    $mdInfo += "| Active privileged assignments | $activePrivilegedCount |`n"
    $mdInfo += "| Eligible privileged assignments | $eligiblePrivilegedCount |`n"
    $mdInfo += "| Non-GA privileged role assignments (deduplicated) | $privilegedRoleAssignmentCount |`n"
    $mdInfo += "| Total privileged role assignments | $totalPrivilegedRoleAssignmentCount |`n"
    $mdInfo += "| **GA to privileged ratio** | **$gaRatioPercentage%** |`n"

    $mdInfo += "`n## Global Administrator assignments`n"

    if ($gaRoleAssignmentCount -gt 0) {
        $mdInfo += "| Display name | User principal name |`n"
        $mdInfo += "| :----------- | :------------------ |`n"
        foreach ($user in ($allGAUsers.Values | Sort-Object displayName)) {
            $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/$($user.id)/hidePreviewBanner~/true"
            $safeDisplayName = Get-SafeMarkdown -Text $user.displayName
            $displayNameLink = "[$safeDisplayName]($userLink)"
            $mdInfo += "| $displayNameLink | $($user.userPrincipalName) |`n"
        }
    } else {
        $mdInfo += "No Global Administrators found.`n"
    }

    # Add section for non-GA privileged users
    $mdInfo += "`n## Non-GA privileged role assignments`n"

    if ($privilegedRoleAssignmentCount -gt 0) {
        $mdInfo += "| Display name | User principal name |`n"
        $mdInfo += "| :----------- | :------------------ |`n"
        foreach ($user in ($allPrivilegedUsers.Values | Sort-Object displayName)) {
            $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/$($user.id)/hidePreviewBanner~/true"
            $safeDisplayName = Get-SafeMarkdown -Text $user.displayName
            $displayNameLink = "[$safeDisplayName]($userLink)"
            $mdInfo += "| $displayNameLink | $($user.userPrincipalName) |`n"
        }
    } else {
        $mdInfo += "No non-GA privileged users found.`n"
    }
    #endregion Report Generation

    #region Assessment Logic
    Write-PSFMessage "Assessment data: GACount=$gaRoleAssignmentCount, PrivilegedCount=$privilegedRoleAssignmentCount, TotalCount=$totalPrivilegedRoleAssignmentCount, GARatio=$gaRatioPercentage%" -Level Verbose

    $hasHealthyRatio = $gaRatioPercentage -lt 30
    $hasModerateRatio = $gaRatioPercentage -ge 30 -and $gaRatioPercentage -lt 50
    $hasHighRatio = $gaRatioPercentage -ge 50

    if ($hasHealthyRatio) {
        $passed = $true
        $testResultMarkdown = "Less than 30% of privileged role assignments in the tenant are Global Administrator.$mdInfo"
    } elseif ($hasModerateRatio) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "Between 30-50% of privileged role assignments in the tenant are Global Administrator.$mdInfo"
    } elseif ($hasHighRatio) {
        $passed = $false
        $testResultMarkdown = "More than 50% of privileged role assignments in the tenant are Global Administrator.$mdInfo"
    } else {
        $passed = $true
        $testResultMarkdown = "No privileged role assignments found in the tenant.$mdInfo"
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
