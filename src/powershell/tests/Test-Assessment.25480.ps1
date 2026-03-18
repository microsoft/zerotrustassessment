<#
.SYNOPSIS
    Checks that Quick Access has assigned users or groups
.DESCRIPTION
    Verifies that the Quick Access application has at least one user or group assigned to it through appRoleAssignedTo.

.NOTES
    Test ID: 25480
    Category: Global Secure Access
    Required API: servicePrincipals with appRoleAssignedTo expansion
#>

function Test-Assessment-25480 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = '25480',
        Title = 'Quick Access has assigned users or groups',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Quick Access user and group assignments'
    Write-ZtProgress -Activity $activity -Status 'Querying Quick Access application'

    # Query 1: Get Quick Access service principal ID
    # Note: Combining $filter with $expand on servicePrincipals can return empty appRoleAssignedTo even when assignments exist
    # Using two-step approach: filter first, then expand by ID to avoid missing appRoleAssignedTo data
    $quickAccessApp = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=tags/any(c:c eq 'NetworkAccessQuickAccessApplication')&`$select=id,appId,displayName" -ApiVersion beta

    $app = $null
    if ($quickAccessApp -and $quickAccessApp.Count -gt 0) {
        # Query 2: Get assignments and assignment requirement using the service principal ID
        $quickAccessAppId = $quickAccessApp[0].id
        Write-ZtProgress -Activity $activity -Status 'Querying Quick Access assignments'
        $app = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$quickAccessAppId`?`$select=id,appId,accountEnabled,appRoleAssignmentRequired&`$expand=appRoleAssignedTo(`$select=principalId,principalType,principalDisplayName)" -ApiVersion beta
    }
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $appRoleAssignments = @()
    $customStatus = $null

    # Check if Quick Access application exists
    if (-not $quickAccessApp -or $quickAccessApp.Count -eq 0) {
        # Quick Access app not configured - Investigate status
        $testResultMarkdown = '⚠️ Quick Access application is not configured in the tenant.'
        $customStatus = 'Investigate'
    }
    elseif (-not $app) {
        # Failed to retrieve app details
        $testResultMarkdown = '⚠️ Unable to retrieve Quick Access application details.'
        $customStatus = 'Investigate'
    }
    else {
        # Check if assignment is required or if there are assignments
        # Pass if: appRoleAssignmentRequired is false (all users have implicit access) OR appRoleAssignedTo has value
        $assignmentRequired = $app.appRoleAssignmentRequired
        $hasAssignments = ($null -ne $app.appRoleAssignedTo -and $app.appRoleAssignedTo.Count -gt 0)

        if (-not $assignmentRequired -or $hasAssignments) {
            $appRoleAssignments = $app.appRoleAssignedTo
            $passed = $true
            $testResultMarkdown = "✅ Quick Access application has users or groups assigned, or does not require explicit assignment. `n`n%TestResult%"
        }
        else {
            # appRoleAssignmentRequired is true AND appRoleAssignedTo is empty
            $passed = $false
            $testResultMarkdown = "❌ Quick Access application does not have user or group assignments. `n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/QuickAccessMenuBlade/~/GlobalSecureAccess'

    $mdInfo = ''

    if ($appRoleAssignments.Count -gt 0) {
        # Build results table with link to Users blade
        $reportTitleLink = "[Quick Access application assignments]($portalLink)"
        $mdInfo += "`n## $reportTitleLink`n`n"
        $mdInfo += "| Member type | Display name |`n"
        $mdInfo += "|-------------|--------------|`n"
        foreach ($assignment in $appRoleAssignments) {
            $memberType = $assignment.principalType
            $displayName = $assignment.principalDisplayName
            $mdInfo += "| $memberType | $displayName |`n"
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25480'
        Title  = 'Quick Access has assigned users or groups'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if Investigate is needed
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
