<#
.SYNOPSIS
    All Microsoft Entra privileged role assignments are managed with PIM
#>

function Test-Assessment-21816 {
    [ZtTest(
        Category = 'Identity',
        ImplementationCost = 'Medium',
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

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if( -not (Get-ZtLicense EntraIDP2) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return
    }

    #region Data Collection
    $activity = 'Checking Microsoft Entra privileged role assignments are managed with PIM'
    Write-ZtProgress -Activity $activity

    $globalAdminRoleId = '62e90394-69f5-4237-9190-012177145e10'
    $permanentGAUserList = @()
    $permanentGAGroupList = @()
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
            $roleMembers = Invoke-ZtGraphRequest -RelativeUri "directoryRoles/$($directoryRole.id)/members" -Select 'userPrincipalName,displayName,id' -ApiVersion beta
            Write-PSFMessage "Found $($roleMembers.Count) members in role $($role.displayName)" -Level Verbose

            foreach ($member in $roleMembers) {
                # Check if assignment is managed by PIM
                $pimAssignment = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleAssignmentScheduleInstances' -Filter "principalId eq '$($member.id)' and roleDefinitionId eq '$($role.templateId)'" -ApiVersion beta
                Write-PSFMessage "PIM assignment check for $($member.displayName): Found=$($pimAssignment.Count) results" -Level Verbose

                if (-not $pimAssignment -or ($pimAssignment.assignmentType -eq 'Assigned' -and $null -eq $pimAssignment.endDateTime)) {
                    # Not managed by PIM or permanent assignment
                    $memberInfo = [PSCustomObject]@{
                        displayName = $member.displayName
                        userPrincipalName = $member.userPrincipalName
                        id = $member.id
                        roleTemplateId = $role.templateId
                        roleDefinitionId = $role.id
                        roleName = $role.displayName
                        isPrivileged = $true
                        assignmentType = if ($pimAssignment) { $pimAssignment.assignmentType } else { 'Not in PIM' }
                    }

                    if ($member.'@odata.type' -eq '#microsoft.graph.user') {
                        $nonPIMPrivilegedUsers += $memberInfo
                    } else {
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
        $gaMembers = Invoke-ZtGraphRequest -RelativeUri "directoryRoles/$($gaDirectoryRole.id)/members" -Select 'userPrincipalName,displayName,id' -ApiVersion beta

        foreach ($member in $gaMembers) {
            # Check if GA assignment is managed by PIM
            $pimAssignment = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleAssignmentScheduleInstances' -Filter "principalId eq '$($member.id)' and roleDefinitionId eq '$globalAdminRoleId'" -ApiVersion beta

            if (-not $pimAssignment -or ($pimAssignment.assignmentType -eq 'Assigned' -and $null -eq $pimAssignment.endDateTime)) {
                # Permanent GA assignment found
                $memberInfo = [PSCustomObject]@{
                    displayName = $member.displayName
                    userPrincipalName = $member.userPrincipalName
                    id = $member.id
                    roleTemplateId = $globalAdminRoleId
                    roleDefinitionId = $gaDirectoryRole.id
                    roleName = 'Global Administrator'
                    isPrivileged = $true
                    assignmentType = if ($pimAssignment) { $pimAssignment.assignmentType } else { 'Not in PIM' }
                }

                if ($member.'@odata.type' -eq '#microsoft.graph.user') {
                    $permanentGAUserList += $memberInfo
                } elseif ($member.'@odata.type' -eq '#microsoft.graph.group') {
                    $permanentGAGroupList += $memberInfo
                    # Get group members - only users
                    $groupMembers = Invoke-ZtGraphRequest -RelativeUri "groups/$($member.id)/members" -Select 'userPrincipalName,displayName,id,onPremisesSyncEnabled' -ApiVersion beta
                    foreach ($groupMember in $groupMembers) {
                        # Only process users, skip service principals
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
                        }
                    }
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

    if (-not $hasPIMUsage) {
        $passed = $false
        $testResultMarkdown = 'No eligible Global Administrator assignments found. PIM usage cannot be confirmed.'
    } elseif ($hasNonPIMPrivileged) {
        $passed = $false
        $testResultMarkdown = 'Found Microsoft Entra privileged role assignments that are not managed with PIM.'
    } elseif ($permanentGACount -gt 2) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = 'Three or more accounts are permanently assigned the Global Administrator role. Review to determine whether these are emergency access accounts.'
    } else {
        $passed = $true
        $testResultMarkdown = 'All Microsoft Entra privileged role assignments are managed with PIM with the exception of up to two standing Global Administrator accounts.'
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
            $groupLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/RolesAndAdministrators/groupId/$($group.id)/menuId/"
            $safeDisplayName = Get-SafeMarkdown -Text $group.displayName
            $displayNameLink = "[$safeDisplayName]($groupLink)"
            $mdInfo += "| $displayNameLink | N/A (Group) | $($group.roleName) | $($group.assignmentType) |`n"
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

    # Only add CustomStatus when it's "Investigate" (more than 2 permanent GAs)
    if ($permanentGACount -gt 2) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
