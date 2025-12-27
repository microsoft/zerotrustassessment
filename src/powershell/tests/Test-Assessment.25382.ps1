<#
.SYNOPSIS
    Validates that traffic forwarding profiles are scoped to appropriate users and groups for controlled deployment.

.DESCRIPTION
    This test checks if enabled traffic forwarding profiles for Microsoft 365, Private Access,
    and Internet Access have proper user/group assignments to ensure controlled rollout
    and prevent security gaps.

.NOTES
    Test ID: 25382
    Category: Global Secure Access
    Required API: networkAccess/forwardingProfiles (beta), servicePrincipals (v1.0)
#>

function Test-Assessment-25382 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Private_Access', 'Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25382,
        Title = 'Traffic forwarding profiles are scoped to appropriate users and groups for controlled deployment',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking traffic forwarding profiles configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting traffic forwarding profiles'

    # Query Q1: Get all traffic forwarding profiles with associations and service principal
    $forwardingProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -Select "id,name,state,trafficForwardingType,associations,servicePrincipal" -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $profileResults = @()
    $hasDisabledProfiles = $false
    $hasEnabledProfileWithoutAssignments = $false
    #endregion Data Collection

    #region Assessment Logic
    # Check each profile's assignments
    if($forwardingProfiles -and $forwardingProfiles.Count -gt 0){
        foreach ($forwardingProfile in $forwardingProfiles) {
                $profileInfo = @{
                    Name = $forwardingProfile.name
                    Type = $forwardingProfile.trafficForwardingType
                    State = $forwardingProfile.state
                    RemoteNetworkCount = ($forwardingProfile.associations ?? @()).Count
                    ServicePrincipalId = $null
                    AppId = $null
                    AssignmentType = 'Not checked'
                    TotalAssignments = 0
                    UserCount = 0
                    GroupCount = 0
                }

                # Handle disabled profiles
                if ($forwardingProfile.state -ne 'enabled') {
                    $hasDisabledProfiles = $true
                    $profileInfo.AssignmentType = 'N/A'
                    $profileResults += $profileInfo
                    continue
                }

                # Handle enabled profiles
                try {
                    $sp = $forwardingProfile.servicePrincipal
                    if (-not $sp) {
                        $profileInfo.AssignmentType = 'Error'
                        $hasEnabledProfileWithoutAssignments = $true
                        $profileResults += $profileInfo
                        continue
                    }

                    $profileInfo.ServicePrincipalId = $sp.id
                    $profileInfo.AppId = $sp.appId

                    Write-ZtProgress -Activity $activity -Status "Checking assignments for $($forwardingProfile.name)"

                    # Query Q2: Get service principal details with app role assignments
                    $servicePrincipal = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$($sp.id)" -Select "appRoleAssignmentRequired" -ApiVersion v1.0 -QueryParameters @{ '$expand' = "appRoleAssignedTo(`$select=principalType)" }

                    if (-not $servicePrincipal.appRoleAssignmentRequired) {
                        # All users assigned - this is valid
                        $profileInfo.AssignmentType = 'All Users'
                        $profileInfo.TotalAssignments = 'All Users'
                    }
                    elseif ($servicePrincipal.appRoleAssignedTo -and $servicePrincipal.appRoleAssignedTo.Count -gt 0) {
                        # Specific assignments exist - count users and groups in single pass
                        $grouped = $servicePrincipal.appRoleAssignedTo | Group-Object -Property principalType -AsHashTable
                        $profileInfo.AssignmentType = 'Specific'
                        $profileInfo.UserCount = ($grouped['User'] ?? @()).Count
                        $profileInfo.GroupCount = ($grouped['Group'] ?? @()).Count
                        $profileInfo.TotalAssignments = $servicePrincipal.appRoleAssignedTo.Count
                    }
                    else {
                        # Assignment required but no assignments found - FAIL
                        $profileInfo.AssignmentType = 'None'
                        $hasEnabledProfileWithoutAssignments = $true
                    }
                }
                catch {
                    Write-PSFMessage "Failed to check assignments for profile $($forwardingProfile.name): $_" -Level Warning
                    $profileInfo.AssignmentType = 'Error'
                    $hasEnabledProfileWithoutAssignments = $true
                }

            $profileResults += $profileInfo
        }
    }
    else {
        # No profiles found or empty - FAIL
        $hasEnabledProfileWithoutAssignments = $true
    }

    # Determine pass/fail/investigate
    if ($hasEnabledProfileWithoutAssignments) {
        $passed = $false
        $testResultMarkdown = "Traffic forwarding profile scoping could not be validated. One or more enabled profiles have no user/group assignments.`n`n%TestResult%"
    }
    elseif ($hasDisabledProfiles) {
        $passed = $false
        $testResultMarkdown = "Some of the Traffic forwarding profiles are disabled, please review your configuration, if this is intentional.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = "Traffic forwarding profiles are scoped appropriately.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($profileResults.Count -gt 0) {
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/ForwardingProfile.ReactView'

        $enabledCount = ($profileResults | Where-Object { $_.State -eq 'enabled' }).Count
        $totalCount = $profileResults.Count

        $mdInfo += "`n## Traffic forwarding profiles summary`n`n"
        $mdInfo += "- **Total Profiles:** $totalCount`n"
        $mdInfo += "- **Enabled Profiles:** $enabledCount`n"
        $mdInfo += "- **Disabled Profiles:** $($totalCount - $enabledCount)`n`n"
        $mdInfo += "## [Traffic forwarding profiles]($portalLink)`n`n"
        $mdInfo += "| Profile name | Type | State | Remote networks count | Users | Groups | Assignment scope |`n"
        $mdInfo += "| :----------- | :--- | :---- | :-------------- | :---- | :----- | :--------------- |`n"

        foreach ($profile in $profileResults) {
            $isEnabled = $profile.State -eq 'enabled'
            $stateDisplay = if ($isEnabled) { '✅ Enabled' } else { '❌ Disabled' }

            $typeLabel = switch ($profile.Type) {
                'm365' { 'Microsoft 365' }
                'internet' { 'Internet' }
                'private' { 'Private Access' }
                default { $profile.Type }
            }

            $usersDisplay = if ($isEnabled -and $profile.AssignmentType -eq 'All Users') { 'All' }
                           elseif ($isEnabled) { $profile.UserCount }
                           else { 'N/A' }

            $groupsDisplay = if ($isEnabled -and $profile.AssignmentType -eq 'All Users') { 'All' }
                            elseif ($isEnabled) { $profile.GroupCount }
                            else { 'N/A' }

            $assignmentScopeDisplay = if (-not $isEnabled) { 'N/A' }
                                     elseif ($profile.AssignmentType -eq 'All Users') { '✅ All Users' }
                                     elseif ($profile.AssignmentType -eq 'Specific') { "Specific ($($profile.TotalAssignments))" }
                                     elseif ($profile.AssignmentType -eq 'None') { '❌ None' }
                                     else { $profile.AssignmentType }

            # Create hyperlink for assignment scope if service principal exists
            if ($profile.ServicePrincipalId -and $profile.AppId -and $isEnabled) {
                $assignmentLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Users/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/' -f $profile.ServicePrincipalId, $profile.AppId
                $assignmentScopeDisplayLink = "[$(Get-SafeMarkdown($assignmentScopeDisplay))]($assignmentLink)"
            } else {
                $assignmentScopeDisplayLink = $assignmentScopeDisplay
            }

            $mdInfo += "| $($profile.Name) | $typeLabel | $stateDisplay | $($profile.RemoteNetworkCount) | $usersDisplay | $groupsDisplay | $assignmentScopeDisplayLink |`n"
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25382'
        Title  = 'Traffic forwarding profiles are scoped to appropriate users and groups for controlled deployment'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($hasDisabledProfiles -and -not $hasEnabledProfileWithoutAssignments) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
