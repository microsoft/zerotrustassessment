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
    $assignmentsList = @('None')
    $hasAssignments = $false
    $appid = $null
    $id = $null

    # Check if Internet Access forwarding profile exists
    if ($forwardingProfile) {
        $profileState = $forwardingProfile.state
        $profileName = $forwardingProfile.name
        $appid = $forwardingProfile.servicePrincipal.appId
        $id = $forwardingProfile.servicePrincipal.id

        try {
            # Fetch only first 6 assignments to check if there are more than 5
            $servicePrincipal = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals(appId='$($appid)')" -Select "appid,appRoleAssignmentRequired" -ApiVersion v1.0 -QueryParameters @{ '$expand' = 'appRoleAssignedTo($select=principalDisplayName;$top=6;$orderby=principalDisplayName)' }

            if ($servicePrincipal) {
                # Pass condition: appRoleAssignmentRequired is False OR appRoleAssignedTo has values
                if ($servicePrincipal.appRoleAssignmentRequired -eq $false) {
                    # Assignment not required: available to everyone regardless of explicit entries
                    $assignmentsList = @('All Users')
                    $hasAssignments = $true
                }
                elseif ($servicePrincipal.appRoleAssignedTo -and $servicePrincipal.appRoleAssignedTo.Count -gt 0) {
                    # Explicit assignments exist - show them with sample (API already sorted and limited to 6)
                    $assignments = $servicePrincipal.appRoleAssignedTo
                    $hasMoreThan5 = $assignments.Count -gt 5

                    if ($hasMoreThan5) {
                        $first5Names = ($assignments | Select-Object -First 5 -ExpandProperty principalDisplayName) -join ', '
                        $assignmentsList = @("$first5Names, ...")
                    }
                    else {
                        $assignmentsList = @(($assignments.principalDisplayName) -join ', ')
                    }
                    $hasAssignments = $true
                }
                else {
                    # appRoleAssignmentRequired = true but no assignments
                    $assignmentsList = @('None')
                    $hasAssignments = $false
                }
            }
        }
        catch {
            Write-PSFMessage "Failed to check service principal assignments: $_" -Level Warning
        }
    }

    # Pass if profile is enabled AND has assignments
    $passed = ($profileState -eq 'Enabled') -and $hasAssignments
    #endregion Data Collection

    #region Assessment Logic
    if ($passed) {
        $testResultMarkdown = "Internet access forwarding profile is enabled with user assignments.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Internet access forwarding profile is disabled or lacks user assignments.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Add visual indicators to display
    $stateDisplay = if ($profileState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }

    $assignmentValue = $assignmentsList[0]
    $assignmentsDisplay = switch ($assignmentValue) {
        'None' { '❌ None' }
        'All Users' { '✅ All Users' }
        default { $assignmentValue }
    }

    if($appid -and $id)
    {
        $groupLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Users/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/' -f $id, $appid
        $assignmentsDisplayLink = "[$(Get-SafeMarkdown($assignmentsDisplay))]($groupLink)"
    }
    else {
        $assignmentsDisplayLink = $assignmentsDisplay
    }

    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/ForwardingProfile.ReactView'
    $profileNameLink = "[$(Get-SafeMarkdown($profileName))]($portalLink)"

    $mdInfo = @"

## Internet access profile

| Profile name | Profile state | Assignments |
| :----------- | :------------ | :---------- |
| $profileNameLink | $stateDisplay | $assignmentsDisplayLink |
"@

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
