<#
.SYNOPSIS
    Validates that the Internet Access forwarding profile is enabled with user assignments.
#>

function Test-Assessment-25406 {
    [ZtTest(
        Category = 'Internet Access Control',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Global_Secure_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25406,
        Title = 'Internet access forwarding profile is enabled',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Internet Access forwarding profile'
    Write-ZtProgress -Activity $activity -Status 'Getting Internet Access forwarding profile'

    # Query Q1: Get Internet Access forwarding profile
    $forwardingProfile = Invoke-ZtGraphRequest -RelativeUri "networkAccess/forwardingProfiles" -Filter "trafficForwardingType eq 'internet'" -Select "name,state,servicePrincipal" -ApiVersion beta

    # Initialize test variables
    $passed = $false
    $profileName = 'Internet traffic forwarding profile'
    $profileState = 'Disabled'
    $assignmentsSummary = '❌ None'
    $hasAssignments = $false
    $appid = $null
    $id = $null
    $allAssignments = @()
    $assignmentsTruncated = $false
    $assignmentLimit = 1000
    $previewLimit = 3
    $totalNoOfAssignments = 0

    # Check if Internet Access forwarding profile exists
    if ($forwardingProfile) {
        $profileState = $forwardingProfile.state
        $profileName = $forwardingProfile.name
        $appid = $forwardingProfile.servicePrincipal.appId
        $id = $forwardingProfile.servicePrincipal.id

        try {
            # Get service principal details
            $servicePrincipal = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$id" -Select "appid,appRoleAssignmentRequired" -ApiVersion v1.0 -QueryParameters @{ '$expand' = "appRoleAssignedTo(`$select=principalId,principalType,principalDisplayName;`$top=$($assignmentLimit + 1))" }

            if ($servicePrincipal) {
                # Pass condition: appRoleAssignmentRequired is False OR appRoleAssignedTo has values
                if ($servicePrincipal.appRoleAssignmentRequired -eq $false) {
                    # Assignment not required: available to everyone - no appendix table needed
                    $assignmentsSummary = '✅ All Users'
                    $hasAssignments = $true
                    $totalNoOfAssignments = 'All Users'
                }elseif ($servicePrincipal.appRoleAssignedTo.Count -gt 0) {
                    # Check if truncated
                    $assignmentsTruncated = $servicePrincipal.appRoleAssignedTo.Count -gt $assignmentLimit
                    $allAssignments = $servicePrincipal.appRoleAssignedTo | Select-Object -First $assignmentLimit | Sort-Object -Property principalDisplayName

                    # Fetch total count only if truncated
                    if ($assignmentsTruncated) {
                        $totalNoOfAssignments = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$id/appRoleAssignedTo/`$count" -ApiVersion v1.0
                    } else {
                        $totalNoOfAssignments = $allAssignments.Count
                    }

                    # Create summary for inline display (shows first X users for preview based on $previewLimit)
                    if ($allAssignments.Count -gt $previewLimit) {
                        $assignmentPreviewNames = ($allAssignments | Select-Object -First $previewLimit -ExpandProperty principalDisplayName) -join ', '
                        $assignmentsSummary = "$assignmentPreviewNames, ..."
                    }else {
                        $assignmentsSummary = ($allAssignments.principalDisplayName) -join ', '
                    }

                    $hasAssignments = $true
                }else {
                    # appRoleAssignmentRequired = true but no assignments
                    $assignmentsSummary = '❌ None'
                    $hasAssignments = $false
                }
            }
        }
        catch {
            Write-PSFMessage "Failed to check service principal assignments: $_" -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    # Pass if profile is enabled AND has assignments
    if ($profileState -eq 'Enabled' -and $hasAssignments) {
        $passed = $true
        $testResultMarkdown = "Internet access forwarding profile is enabled with user assignments.`n`n%TestResult%"
    }else {
        $passed = $false
        $testResultMarkdown = "Internet access forwarding profile is disabled or lacks user assignments.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Add visual indicators to display
    $stateDisplay = if ($profileState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }

    if ($appid -and $id) {
        $groupLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Users/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/' -f $id, $appid
        $assignmentsSummaryLink = "[$(Get-SafeMarkdown($assignmentsSummary))]($groupLink)"
    }else {
        $assignmentsSummaryLink = $assignmentsSummary
    }

    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/ForwardingProfile.ReactView'
    $profileNameLink = "[$(Get-SafeMarkdown($profileName))]($portalLink)"

    $mdInfo += @"

## Internet access profile

| Profile name | Profile state | Assignments | Assignment count |
| :----------- | :------------ | :---------- | :---------- |
| $profileNameLink | $stateDisplay | $assignmentsSummaryLink | $totalNoOfAssignments |
"@

    # Add detailed assignments table only if explicit assignments exist
    if ($allAssignments.Count -gt 0) {
        $mdInfo += "`n`n## User/Group assignments"
        $mdInfo += "`n`n| Principal display name  | Principal type | Principal id |"
        $mdInfo += "`n| :------------- | :----------- | :----------- |"

        foreach ($assignment in $allAssignments) {
            # Create portal link based on principal type
            $principalLink = switch ($assignment.principalType) {
                'User' { "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/$($assignment.principalId)" }
                'Group' { "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/$($assignment.principalId)" }
                default { $null }
            }

            $displayNameText = Get-SafeMarkdown($assignment.principalDisplayName)
            $displayNameLink = if ($principalLink) { "[$displayNameText]($principalLink)" } else { $displayNameText }

            $mdInfo += "`n| $displayNameLink | $($assignment.principalType) | $($assignment.principalId) |"
        }

        if ($assignmentsTruncated) {
            $mdInfo += "`n`n_**Note**: This table is truncated and showing the first $assignmentLimit assignments out of $totalNoOfAssignments total._"
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25406'
        Title  = 'Internet access forwarding profile is enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
