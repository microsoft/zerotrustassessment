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
    Write-ZtProgress -Activity $activity -Status 'Querying Quick Access application and assigned users/groups'

    # Query 1: Find Quick Access application with appRoleAssignedTo expansion
    # executing the original query in graph explorer ignores $select and returns complete entity. A Q&A thread mentions no support for nested $select on expanded directory object relationships [known-issues](https://developer.microsoft.com/en-us/graph/known-issues/?search=13635)
    $app = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=tags/any(c:c eq 'NetworkAccessQuickAccessApplication')&`$expand=appRoleAssignedTo" -ApiVersion beta
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $appRoleAssignments = @()
    $customStatus = $null

    # Check if Quick Access application exists
    if (-not $app -or $app.Count -eq 0) {
        # Quick Access app not configured - Investigate status
        $testResultMarkdown = '⚠️ Quick Access application is not configured in the tenant. Customers should review the documentation on how to enable Quick Access.'
        $customStatus = 'Investigate'
    }
    else {
        # Check appRoleAssignedTo
        if ($null -ne $app.appRoleAssignedTo -and $app.appRoleAssignedTo.Count -gt 0) {
            $appRoleAssignments = $app.appRoleAssignedTo
            $passed = $true
            $testResultMarkdown = "✅ Quick Access application has users or groups assigned. `n`n%TestResult%"
        }
        else {
            # appRoleAssignedTo is empty, null, or contains no entries
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
