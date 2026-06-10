<#
.SYNOPSIS
    All Microsoft Entra privileged role assignments are managed with PIM
#>

function Test-Assessment-21816 {
    [ZtTest(
    	Category = 'Privileged access',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P2'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21816,
    	Title = 'All Microsoft Entra privileged role assignments are managed with PIM',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    if( -not (Get-ZtLicense EntraIDP2) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return
    }

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Entra privileged role assignments are managed with PIM'
    Write-ZtProgress -Activity $activity

    $globalAdminRoleId = '62e90394-69f5-4237-9190-012177145e10'
    $permanentGAUserList = @()
    $nonPIMPrivilegedUsers = @()
    $nonPIMPrivilegedGroups = @()

    # Query 1: Find all privileged directory roles
    Write-ZtProgress -Activity $activity -Status 'Getting privileged directory roles'
    $privilegedRoles = Get-ZtRole -IncludePrivilegedRoles
    Write-PSFMessage "Found $($privilegedRoles.Count) privileged roles" -Level Verbose

    # Query 2: Check for eligible Global Administrators (PIM usage confirmation)
    Write-ZtProgress -Activity $activity -Status 'Checking eligible Global Administrators'
    $eligibleGAs = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleEligibilitySchedules' -Filter "roleDefinitionId eq '$globalAdminRoleId'" -ApiVersion beta
    Write-PSFMessage "Found $($eligibleGAs.Count) eligible GA assignments" -Level Verbose

    $eligibleGAUsers = 0
    foreach ($eligibleGA in $eligibleGAs) {
        # Get principal information separately
        $principal = Invoke-ZtGraphRequest -RelativeUri "directoryObjects/$($eligibleGA.principalId)" -ApiVersion beta

        if ($principal.'@odata.type' -eq '#microsoft.graph.user') {
            $eligibleGAUsers++
        } elseif ($principal.'@odata.type' -eq '#microsoft.graph.group') {
            # Get group members for eligible GA groups
            $groupMembers = Invoke-ZtGraphRequest -RelativeUri "groups/$($principal.id)/members" -Select 'userPrincipalName,displayName,id' -ApiVersion beta
            $eligibleGAUsers += $groupMembers.Count
        }
    }

    # Process each privileged role (excluding Global Administrator for now)
    Write-ZtProgress -Activity $activity -Status 'Checking privileged role assignments'
    foreach ($role in $privilegedRoles) {
        if ($role.templateId -eq $globalAdminRoleId) { continue } # Skip GA, handle separately

        Write-PSFMessage "Processing role: $($role.displayName)" -Level Verbose
        # Find directory role instance
        $directoryRole = Invoke-ZtGraphRequest -RelativeUri 'directoryRoles' -Filter "roleTemplateId eq '$($role.templateId)'" -ApiVersion beta

        if ($directoryRole) {
            Write-PSFMessage "Found directory role instance for $($role.displayName)" -Level Verbose
            # Get members of this role
            # Raw call required — Get-ZtRoleMember flattens group members; group objects are needed to check PIM for Groups
            $roleMembers = Invoke-ZtGraphRequest -RelativeUri "directoryRoles/$($directoryRole.id)/members" -Select 'id,displayName,userPrincipalName,appId' -ApiVersion beta
            Write-PSFMessage "Found $($roleMembers.Count) members in role $($role.displayName)" -Level Verbose

            foreach ($member in $roleMembers) {
                # Check if assignment is managed by PIM
                $pimAssignment = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleAssignmentScheduleInstances' -Filter "principalId eq '$($member.id)' and roleDefinitionId eq '$($role.templateId)'" -ApiVersion beta
                Write-PSFMessage "PIM assignment check for $($member.displayName): Found=$($pimAssignment.Count) results" -Level Verbose

                # Permanent active assignment = AssignmentType 'Assigned' with no endDateTime (spec requirement).
                # Time-limited active assignments (Assigned + non-null endDateTime) are PIM-managed and must not be flagged.
                # Where-Object handles the collection correctly; direct property access on an array is unreliable.
                $hasPermAssignment = @($pimAssignment | Where-Object { $_.assignmentType -eq 'Assigned' -and $null -eq $_.endDateTime })
                if (-not $pimAssignment -or $hasPermAssignment.Count -gt 0) {
                    # Not managed by PIM or standing active assignment
                    $memberInfo = [PSCustomObject]@{
                        displayName = $member.displayName
                        userPrincipalName = $member.userPrincipalName
                        id = $member.id
                        appId = $member.appId
                        principalType = $member.'@odata.type'
                        roleTemplateId = $role.templateId
                        roleDefinitionId = $role.id
                        roleName = $role.displayName
                        isPrivileged = $true
                        assignmentType = if ($hasPermAssignment.Count -gt 0) { ($hasPermAssignment | Select-Object -First 1).assignmentType } else { 'Not in PIM' }
                    }

                    if ($member.'@odata.type' -eq '#microsoft.graph.user') {
                        $nonPIMPrivilegedUsers += $memberInfo
                    } elseif ($member.'@odata.type' -eq '#microsoft.graph.group') {
                        # Q5: Check if the group uses PIM for Groups to enforce JIT member access
                        $pimForGroupsSchedules = $null
                        $pimForGroupsPermanentMembers = @()
                        try {
                            $pimForGroupsSchedules = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/privilegedAccess/group/eligibilityScheduleInstances' -Filter "groupId eq '$($member.id)' and accessId eq 'member'" -ApiVersion beta -ErrorAction Stop
                            if ($pimForGroupsSchedules) {
                                # Also check for permanent active member assignments alongside eligibility schedules
                                $allGroupAssignments = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/privilegedAccess/group/assignmentScheduleInstances' -Filter "groupId eq '$($member.id)' and accessId eq 'member'" -ApiVersion beta -ErrorAction Stop
                                # 'assigned' = direct standing membership (always non-null endDateTime in this API, unlike roleAssignmentScheduleInstances).
                                # 'activated' = JIT self-activation of an eligibility — not standing access.
                                $pimForGroupsPermanentMembers = @($allGroupAssignments | Where-Object { $_.assignmentType -eq 'assigned' })
                            }
                        } catch {
                            Write-PSFMessage "Could not check PIM for Groups for group $($member.displayName): $($_.Exception.Message). Treating as non-PIM managed." -Level Warning
                        }
                        if (-not $pimForGroupsSchedules -or $pimForGroupsPermanentMembers.Count -gt 0) {
                            # Group does not use PIM for Groups, or has permanent active members alongside eligibility schedules
                            $nonPIMPrivilegedGroups += $memberInfo
                        }
                    } else {
                        # Service principal or other object type — PIM for Groups does not apply; always standing access
                        $nonPIMPrivilegedGroups += $memberInfo
                    }
                }
            }
        }
    }

    # Query 3: Handle Global Administrator role separately
    Write-ZtProgress -Activity $activity -Status 'Checking Global Administrator assignments'
    $gaDirectoryRole = Invoke-ZtGraphRequest -RelativeUri 'directoryRoles' -Filter "roleTemplateId eq '$globalAdminRoleId'" -ApiVersion beta

    if ($gaDirectoryRole) {
        # Raw call required — Get-ZtRoleMember flattens group members; group objects are needed to check PIM for Groups
        # @odata.type is an OData annotation returned automatically in polymorphic collections; it cannot be listed in $select
        $gaMembers = Invoke-ZtGraphRequest -RelativeUri "directoryRoles/$($gaDirectoryRole.id)/members" -Select 'id,displayName,userPrincipalName,appId' -ApiVersion beta

        foreach ($member in $gaMembers) {
            # Check if GA assignment is managed by PIM
            $pimAssignment = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleAssignmentScheduleInstances' -Filter "principalId eq '$($member.id)' and roleDefinitionId eq '$globalAdminRoleId'" -ApiVersion beta

            # Permanent active assignment = AssignmentType 'Assigned' with no endDateTime (spec requirement).
            # Time-limited active assignments (Assigned + non-null endDateTime) are PIM-managed and must not be flagged.
            # Where-Object handles the collection correctly; direct property access on an array is unreliable.
            $hasPermAssignment = @($pimAssignment | Where-Object { $_.assignmentType -eq 'Assigned' -and $null -eq $_.endDateTime })
            if (-not $pimAssignment -or $hasPermAssignment.Count -gt 0) {
                # Standing active GA assignment found
                $memberInfo = [PSCustomObject]@{
                    displayName = $member.displayName
                    userPrincipalName = $member.userPrincipalName
                    id = $member.id
                    appId = $member.appId
                    principalType = $member.'@odata.type'
                    roleTemplateId = $globalAdminRoleId
                    roleDefinitionId = $gaDirectoryRole.id
                    roleName = 'Global Administrator'
                    isPrivileged = $true
                        assignmentType = if ($hasPermAssignment.Count -gt 0) { ($hasPermAssignment | Select-Object -First 1).assignmentType } else { 'Not in PIM' }
                }

                if ($member.'@odata.type' -eq '#microsoft.graph.user') {
                    $permanentGAUserList += $memberInfo
                } elseif ($member.'@odata.type' -eq '#microsoft.graph.group') {
                    # Q4: Check if the group uses PIM for Groups to enforce JIT member access
                    $pimForGroupsSchedules = $null
                    $pimForGroupsPermanentMembers = @()
                    try {
                        $pimForGroupsSchedules = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/privilegedAccess/group/eligibilityScheduleInstances' -Filter "groupId eq '$($member.id)' and accessId eq 'member'" -ApiVersion beta -ErrorAction Stop
                        if ($pimForGroupsSchedules) {
                            # Also check for permanent active member assignments alongside eligibility schedules
                            $allGroupAssignments = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/privilegedAccess/group/assignmentScheduleInstances' -Filter "groupId eq '$($member.id)' and accessId eq 'member'" -ApiVersion beta -ErrorAction Stop
                            # 'assigned' = direct standing membership (always non-null endDateTime in this API, unlike roleAssignmentScheduleInstances).
                            # 'activated' = JIT self-activation of an eligibility — not standing access.
                            $pimForGroupsPermanentMembers = @($allGroupAssignments | Where-Object { $_.assignmentType -eq 'assigned' })
                        }
                    } catch {
                        Write-PSFMessage "Could not check PIM for Groups for group $($member.displayName): $($_.Exception.Message). Treating as non-PIM managed." -Level Warning
                    }
                    if ($pimForGroupsSchedules -and $pimForGroupsPermanentMembers.Count -eq 0) {
                        # Group enforces JIT via PIM for Groups with no permanent members - skip member expansion
                        Write-PSFMessage "Group $($member.displayName) uses PIM for Groups with no permanent members, excluding from permanent GA list" -Level Verbose
                    } else {
                        # Group does not use PIM for Groups - get members and add to permanentGAUserList (Q4)
                        $groupMembers = Invoke-ZtGraphRequest -RelativeUri "groups/$($member.id)/members" -ApiVersion beta
                        foreach ($groupMember in $groupMembers) {
                            if ($groupMember.'@odata.type' -eq '#microsoft.graph.user') {
                                $groupMemberInfo = [PSCustomObject]@{
                                    displayName = $groupMember.displayName
                                    userPrincipalName = $groupMember.userPrincipalName
                                    id = $groupMember.id
                                    roleTemplateId = $globalAdminRoleId
                                    roleDefinitionId = $gaDirectoryRole.id
                                    roleName = 'Global Administrator (via group)'
                                    isPrivileged = $true
                                    assignmentType = 'Via Group'
                                    onPremisesSyncEnabled = $groupMember.onPremisesSyncEnabled
                                }
                                $permanentGAUserList += $groupMemberInfo
                            } elseif ($groupMember.'@odata.type' -eq '#microsoft.graph.servicePrincipal') {
                                # SP inside a non-PIM-managed GA group has standing GA access — surface it in the non-PIM table
                                $spMemberInfo = [PSCustomObject]@{
                                    displayName = $groupMember.displayName
                                    userPrincipalName = $null
                                    id = $groupMember.id
                                    appId = $groupMember.appId
                                    principalType = $groupMember.'@odata.type'
                                    roleTemplateId = $globalAdminRoleId
                                    roleDefinitionId = $gaDirectoryRole.id
                                    roleName = 'Global Administrator (via group)'
                                    isPrivileged = $true
                                    assignmentType = 'Via Group'
                                }
                                $nonPIMPrivilegedGroups += $spMemberInfo
                            }
                        }
                    }
                } else {
                    # Service principal or other object type — PIM for Groups does not apply; always standing access
                    $nonPIMPrivilegedGroups += $memberInfo
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    Write-PSFMessage "Assessment data: EligibleGAUsers=$eligibleGAUsers, NonPIMPrivileged=$($nonPIMPrivilegedUsers.Count + $nonPIMPrivilegedGroups.Count), PermanentGA=$($permanentGAUserList.Count)" -Level Verbose

    $hasPIMUsage = $eligibleGAUsers -gt 0
    $hasNonPIMPrivileged = ($nonPIMPrivilegedUsers.Count + $nonPIMPrivilegedGroups.Count) -gt 0
    $permanentGACount = $permanentGAUserList.Count
    $customStatus = $null

    if (-not $hasPIMUsage) {
        $passed = $false
        $testResultMarkdown = 'No eligible Global Administrator assignments found. PIM usage cannot be confirmed.'
    } elseif ($hasNonPIMPrivileged) {
        $passed = $false
        $testResultMarkdown = 'Found Microsoft Entra privileged role assignments that are not managed with PIM.'
    } elseif ($permanentGACount -gt 2) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = 'Three or more accounts are permanently assigned the Global Administrator role. Review to determine whether these are emergency access accounts configured in accordance with Microsoft guidance.'
    } else {
        $passed = $true
        $testResultMarkdown = 'All Microsoft Entra privileged role assignments are managed with PIM with the exception of up to two standing Global Administrator accounts that are permitted by this check for emergency access.'
    }

    $testResultMarkdown += "`n`n%TestResult%"
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Always show summary information
    $mdInfo += "`n## Assessment summary`n`n"
    $mdInfo += "| Metric | Count |`n"
    $mdInfo += "| :----- | :---- |`n"
    $mdInfo += "| Privileged roles found | $($privilegedRoles.Count) |`n"
    $mdInfo += "| Eligible Global Administrators | $($eligibleGAUsers) |`n"
    $mdInfo += "| Non-PIM privileged users | $($nonPIMPrivilegedUsers.Count) |`n"
    $mdInfo += "| Non-PIM privileged groups | $($nonPIMPrivilegedGroups.Count) |`n"
    $mdInfo += "| Permanent Global Administrator users | $($permanentGAUserList.Count) |`n"

    if ($nonPIMPrivilegedUsers.Count -gt 0 -or $nonPIMPrivilegedGroups.Count -gt 0) {
        $mdInfo += "`n## Non-PIM managed privileged role assignments`n`n"
        $mdInfo += "| Display name | User principal name | Role name | Assignment type |`n"
        $mdInfo += "| :----------- | :------------------ | :-------- | :-------------- |`n"

        foreach ($user in $nonPIMPrivilegedUsers) {
            $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/$($user.id)/hidePreviewBanner~/true"
            $safeDisplayName = Get-SafeMarkdown -Text $user.displayName
            $displayNameLink = "[$safeDisplayName]($userLink)"
            $mdInfo += "| $displayNameLink | $($user.userPrincipalName) | $($user.roleName) | $($user.assignmentType) |`n"
        }

        foreach ($group in $nonPIMPrivilegedGroups) {
            $safeDisplayName = Get-SafeMarkdown -Text $group.displayName
            if ($group.principalType -eq '#microsoft.graph.servicePrincipal') {
                $spLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($group.id)/appId/$($group.appId)"
                $displayNameLink = "[$safeDisplayName]($spLink)"
                $principalLabel = 'N/A (Service Principal)'
            } else {
                $groupLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/RolesAndAdministrators/groupId/$($group.id)/menuId/"
                $displayNameLink = "[$safeDisplayName]($groupLink)"
                $principalLabel = 'N/A (Group)'
            }
            $mdInfo += "| $displayNameLink | $principalLabel | $($group.roleName) | $($group.assignmentType) |`n"
        }
    }

    if ($permanentGAUserList.Count -gt 0) {
        $mdInfo += "`n## Permanent Global Administrator assignments`n`n"
        $mdInfo += "| Display name | User principal name | Assignment type | On-Premises synced |`n"
        $mdInfo += "| :----------- | :------------------ | :-------------- | :----------------- |`n"

        foreach ($user in $permanentGAUserList) {
            $syncStatus = if ($null -ne $user.onPremisesSyncEnabled) { $user.onPremisesSyncEnabled } else { 'N/A' }
            $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/$($user.id)/hidePreviewBanner~/true"
            $safeDisplayName = Get-SafeMarkdown -Text $user.displayName
            $displayNameLink = "[$safeDisplayName]($userLink)"
            $mdInfo += "| $displayNameLink | $($user.userPrincipalName) | $($user.assignmentType) | $syncStatus |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '21816'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
